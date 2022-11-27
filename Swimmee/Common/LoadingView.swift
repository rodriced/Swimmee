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

    init()
    
    func refreshedLoadedData(_ loadedData: LoadedData)
    var restartLoader: (() -> Void)? { get set }
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
        case idle, loading, ready, failure(Error)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.loading, .loading),
                 (.ready, .ready),
                 (.failure, .failure):
                return true
            default:
                return false
            }
        }
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

    lazy var targetVM = {
        var vm = TargetViewModel()
        vm.restartLoader = self.startLoader
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

    func startLoader() {
        print("LoadingViewModel.startLoader")
        cancellable = publisherBuilder()
        #if DEBUG
            .print("LoadingViewModel loader stream ref \(debugStreamRef)")
        #endif
//            .retry(1)
            .sink { [weak self] completion in
                print("LoadingViewModelV2 loader handleEvents \(String(describing: completion))")

                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] data in
                guard let self else { return }

                self.targetVM.refreshedLoadedData(data)
                if self.state != .ready { self.state = .ready }
            }
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
            case .ready:
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
