//
//  LoadingView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 15/11/2022.
//

import SwiftUI

import Combine
import SwiftUI

protocol LoadableViewModel: ObservableObject {
    associatedtype LoadedData
//    : Equatable
    init()
    func injectLoadedData(_ loadedData: LoadedData)
    var reload: (() -> Void)? { get set }
}

#if DEBUG
    var _debugStreamRef = 0
    var debugStreamRef: Int {
        let current = _debugStreamRef
        _debugStreamRef += 1
        return current
    }
#endif

class LoadingViewModel<TargetViewModel: LoadableViewModel>: ObservableObject {
    typealias LoadPublisher = AnyPublisher<TargetViewModel.LoadedData, Error>

    enum LodingState: Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.reloading, .reloading), (.loaded, .loaded), (.failure(_), .failure(_)):
                return true
            default:
                return false
            }
        }

        case idle, loading, reloading, loaded, failure(Error)

//        func assignIfNecessary(to newState: Self) {
//            if self != newState { self = newState }
//        }
    }

    init(publisherBuiler: @escaping () -> LoadPublisher) {
        print("LoadingViewModel.init")
        self.publisherBuilder = publisherBuiler
    }
    
    deinit {
        print("LoadingViewModel.deinit")
    }

    let publisherBuilder: () -> LoadPublisher

    @Published var state = LodingState.idle

//    @Published var targetVM = TargetViewModel()
    lazy var targetVM = {
        var vm = TargetViewModel()
        vm.reload = self.reload
        return vm
    }()

    var cancellable: Cancellable? {
        didSet {
            print("LoadingViewModel.cancellable set ? \(cancellable != nil)")
        }
    }

    func load() {
        print("LoadingViewModel.load")

        state = .loading

        startLoader()
    }

    func reload() {
        print("LoadingViewModel.reload")

        state = .reloading

        startLoader()
    }

    func startLoader() {
        cancellable = publisherBuilder()
        #if DEBUG
            .print("LoadingViewModel loader stream ref \(debugStreamRef)")
        #endif
//            .retry(1)
            .asResult()
            .handleEvents(receiveCompletion: {completion in
                print("LoadingViewModel loader handleEvents \(String(describing: completion))")
            })
            .sink { [weak self] result in
                switch result {
                case .success(let item):
                    self?.targetVM.injectLoadedData(item)
                    if self?.state != .loaded { self?.state = .loaded }
                //                    state.assignIfNecessary(to: .loaded)

                case .failure(let error):
                    self?.state = .failure(error)
                }
            }

//        cancellable = publisherBuilder()
//        #if DEBUG
//            .print("Debug publish count \(debugStreamRef)")
//        #endif
//            .retry(3)
//            //            .removeDuplicates()
//            .sink { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.state = .failure(error)
//                }
//            } receiveValue: { [weak self] in
//                self?.targetVM.injectLoadedData($0)
//                if self?.state != .loaded { self?.state = .loaded }
//            }
    }
}

struct LoadingView<TargetViewModel: LoadableViewModel, TargetView: View>: View {
    @StateObject var loadingVM: LoadingViewModel<TargetViewModel>

    let content: (TargetViewModel) -> TargetView

    init(publisherBuiler: @escaping () -> LoadingViewModel<TargetViewModel>.LoadPublisher,
         @ViewBuilder content: @escaping (TargetViewModel) -> TargetView)
    {
        print("LoadingView.init")
        self._loadingVM = StateObject(wrappedValue: LoadingViewModel(publisherBuiler: publisherBuiler))
        self.content = content
    }

    var body: some View {
        Group {
            DebugHelper.viewBodyPrint("LoadingView.body state = \(loadingVM.state)")
            switch loadingVM.state {
            case .idle:
                Color.clear
                    .onAppear(perform: loadingVM.load)
            case .loading:
                ProgressView()
            case .loaded, .reloading:
                content(loadingVM.targetVM)
            case .failure(let error):
                VStack {
                    Text("\(error.localizedDescription)\nVerify your connectivity\nand come back on this page.")
                    Button("Retry") {
                        loadingVM.state = .idle
                    }
                }
            }
        }
    }
}
