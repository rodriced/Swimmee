//
//  LoadingView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 15/11/2022.
//

import SwiftUI

import Combine
import SwiftUI

protocol ViewModelConfig {
    static var `default`: Self { get }
}

final class ViewModelEmptyConfig: ViewModelConfig {
    static let `default` = ViewModelEmptyConfig()
}

protocol LoadableViewModel: ObservableObject {
    associatedtype LoadedData
    associatedtype Config: ViewModelConfig

    init(initialData: LoadedData, config: Config)

    func refreshedLoadedData(_ loadedData: LoadedData)
    var restartLoader: (() -> Void)? { get set }
}

//#if DEBUG
//    var _debugStreamRef = 0
//    var debugStreamRef: Int {
//        let current = _debugStreamRef
//        _debugStreamRef += 1
//        return current
//    }
//#endif

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

    init(publisherBuiler: @escaping () -> LoadPublisher,
         targetViewModelConfig: TargetViewModel.Config)
    {
//        print("LoadingViewModel.init")
        self.publisherBuilder = publisherBuiler
        self.targetViewModelConfig = targetViewModelConfig
    }

//    deinit {
//        print("LoadingViewModel.deinit")
//    }

    let publisherBuilder: () -> LoadPublisher
    let targetViewModelConfig: TargetViewModel.Config

    @Published var state = LodingState.idle

    var targetViewModel: TargetViewModel?

    func createTargetViewModel(loadedData: TargetViewModel.LoadedData) -> TargetViewModel {
        let vm = TargetViewModel(initialData: loadedData, config: targetViewModelConfig)
        vm.restartLoader = startLoader
        return vm
    }

    var cancellable: Cancellable?
//    {
//        didSet {
//            print("LoadingViewModel.cancellable set ? \(cancellable != nil)")
//        }
//    }

    func load() {
//        print("LoadingViewModel.load")

        state = .loading

        startLoader()
    }

    func startLoader() {
        cancellable = publisherBuilder()
//        #if DEBUG
//            .print("LoadingViewModel loader stream ref \(debugStreamRef)")
//        #endif
//            .retry(1)
            .sink { [weak self] completion in
//                print("LoadingViewModel loader handleEvents \(String(describing: completion))")

                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] data in
                guard let self else { return }

                if let targetViewModel = self.targetViewModel {
                    targetViewModel.refreshedLoadedData(data)
                } else {
                    let targetViewModel = self.createTargetViewModel(loadedData: data)
                    self.targetViewModel = targetViewModel
                }
                if self.state != .ready { self.state = .ready }
            }

//            .sink { [weak self] result in
//                guard let self else { return }
//
//                switch result {
//                case .success(let item):
//                    if let targetViewModel = self.targetViewModel {
//                        targetViewModel.refreshedLoadedData(item)
//                    } else {
//                        let targetViewModel = self.createTargetVM(loadedData: item)
//                        self.targetViewModel = targetViewModel
//                    }
//                    if self.state != .ready { self.state = .ready }
//
//                case .failure(let error):
//                    self.state = .failure(error)
//                }
//            }
    }
}

struct LoadingView<TargetViewModel: LoadableViewModel, TargetView: View>: View {
    @StateObject var loadingViewModel: LoadingViewModel<TargetViewModel>

    let targetView: (TargetViewModel) -> TargetView

    init(publisherBuiler: @escaping () -> LoadingViewModel<TargetViewModel>.LoadPublisher,
         targetViewModelConfig: TargetViewModel.Config = .default,
         @ViewBuilder targetView: @escaping (TargetViewModel) -> TargetView)
    {
//        print("LoadingView.init")
        self._loadingViewModel = StateObject(wrappedValue:
            LoadingViewModel(publisherBuiler: publisherBuiler, targetViewModelConfig: targetViewModelConfig)
        )
        self.targetView = targetView
    }

    var body: some View {
        Group {
//            DebugHelper.viewBodyPrint("LoadingView.body state = \(loadingViewModel.state)")
            switch loadingViewModel.state {
            case .idle:
                Color.clear
                    .onAppear(perform: loadingViewModel.load)
            case .loading:
                ProgressView()
            case .ready:
                if let targetViewModel = loadingViewModel.targetViewModel {
                    targetView(targetViewModel)
                } else {
                    VStack {
                        Text("Fatal error.\nVerify your connectivity\nand come back on this page.")
                        Button("Retry") {
                            loadingViewModel.state = .idle
                        }
                    }
                }
            case .failure(let error):
                VStack {
                    Text("\(error.localizedDescription)\nVerify your connectivity\nand come back on this page.")
                    Button("Retry") {
                        loadingViewModel.state = .idle
                    }
                }
            }
        }
    }
}
