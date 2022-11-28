//
//  LoadingViewV2.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 15/11/2022.
//

import SwiftUI

import Combine
import SwiftUI

protocol LoadableViewModelV2: ObservableObject {
    associatedtype LoadedData

    init(initialData: LoadedData)

    func refreshedLoadedData(_ loadedData: LoadedData)
    var restartLoader: (() -> Void)? { get set }
}

// #if DEBUG
//    var _debugStreamRef = 0
//    var debugStreamRef: Int {
//        let current = _debugStreamRef
//        _debugStreamRef += 1
//        return current
//    }
// #endif

class LoadingViewModelV2<TargetViewModel: LoadableViewModelV2>: ObservableObject {
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
        print("LoadingViewModelV2.init")
        self.publisherBuilder = publisherBuiler
    }

    deinit {
        print("LoadingViewModelV2.deinit")
    }

    let publisherBuilder: () -> LoadPublisher

    @Published var state = LodingState.idle

    var targetVM: TargetViewModel?

    func createTargetVM(loadedData: TargetViewModel.LoadedData) -> TargetViewModel {
        let vm = TargetViewModel(initialData: loadedData)
        vm.restartLoader = startLoader
        return vm
    }

    var cancellable: Cancellable? {
        didSet {
            print("LoadingViewModelV2.cancellable set ? \(cancellable != nil)")
        }
    }

    func load() {
        print("LoadingViewModelV2.load")

        state = .loading

        startLoader()
    }

    func startLoader() {
        cancellable = publisherBuilder()
        #if DEBUG
            .print("LoadingViewModelV2 loader stream ref \(debugStreamRef)")
        #endif
//            .retry(1)
            .sink { [weak self] completion in
                print("LoadingViewModelV2 loader handleEvents \(String(describing: completion))")

                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] data in
                guard let self else { return }

                if let targetVM = self.targetVM {
                    targetVM.refreshedLoadedData(data)
                } else {
                    let targetVM = self.createTargetVM(loadedData: data)
                    self.targetVM = targetVM
                }
                if self.state != .ready { self.state = .ready }
            }

//            .sink { [weak self] result in
//                guard let self else { return }
//
//                switch result {
//                case .success(let item):
//                    if let targetVM = self.targetVM {
//                        targetVM.refreshedLoadedData(item)
//                    } else {
//                        let targetVM = self.createTargetVM(loadedData: item)
//                        self.targetVM = targetVM
//                    }
//                    if self.state != .ready { self.state = .ready }
//
//                case .failure(let error):
//                    self.state = .failure(error)
//                }
//            }
    }
}

struct LoadingViewV2<TargetViewModel: LoadableViewModelV2, TargetView: View>: View {
    @StateObject var loadingVM: LoadingViewModelV2<TargetViewModel>

    let content: (TargetViewModel) -> TargetView

    init(publisherBuiler: @escaping () -> LoadingViewModelV2<TargetViewModel>.LoadPublisher,
         @ViewBuilder content: @escaping (TargetViewModel) -> TargetView)
    {
        print("LoadingViewV2.init")
        self._loadingVM = StateObject(wrappedValue: LoadingViewModelV2(publisherBuiler: publisherBuiler))
        self.content = content
    }

    var body: some View {
        Group {
            DebugHelper.viewBodyPrint("LoadingViewV2.body state = \(loadingVM.state)")
            switch loadingVM.state {
            case .idle:
                Color.clear
                    .onAppear(perform: loadingVM.load)
            case .loading:
                ProgressView()
            case .ready:
                if let targetVM = loadingVM.targetVM {
                    content(targetVM)
                } else {
                    VStack {
                        Text("Fatal error.\nVerify your connectivity\nand come back on this page.")
                        Button("Retry") {
                            loadingVM.state = .idle
                        }
                    }
                }
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
