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
}

class LoadingViewModel<TargetViewModel: LoadableViewModel>: ObservableObject {
    typealias LoadPublisher = AnyPublisher<TargetViewModel.LoadedData, Error>

    enum LodingState: Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.failure(_), .failure(_)):
                return true
            default:
                return false
            }
        }

        case idle, loading, loaded, failure(Error)

//        func assignIfNecessary(to newState: Self) {
//            if self != newState { self = newState }
//        }
    }

    init(publisherBuiler: @escaping () -> LoadPublisher) {
        print("ViewModel.init")
        self.publisherBuilder = publisherBuiler
    }

    let publisherBuilder: () -> LoadPublisher

    @Published var state = LodingState.idle

//    @Published var targetVM = TargetViewModel()
    let targetVM = TargetViewModel()

    var cancellable: Cancellable?

    func load() {
        print("ViewModel.load")

        state = .loading

//        cancellable = publisherBuilder().asResult()
//            .sink { [weak self] result in
//                switch result {
//                case .success(let item):
//                    self?.targetVM.injectLoadedData(item)
//                    if self?.state != .loaded { self?.state = .loaded }
        ////                    state.assignIfNecessary(to: .loaded)
//
//                case .failure(let error):
//                    self?.state = .failure(error)
//                }
//            }

        cancellable = publisherBuilder()
//            .removeDuplicates()
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] in
                self?.targetVM.injectLoadedData($0)
                if self?.state != .loaded { self?.state = .loaded }
            }
    }
}

struct LoadingView<TargetViewModel: LoadableViewModel, TargetView: View>: View {
    @StateObject var loadingVM: LoadingViewModel<TargetViewModel>

    let content: (TargetViewModel) -> TargetView

    init(publisherBuiler: @escaping () -> LoadingViewModel<TargetViewModel>.LoadPublisher,
         @ViewBuilder content: @escaping (TargetViewModel) -> TargetView)
    {
        print("View.init")
        self._loadingVM = StateObject(wrappedValue: LoadingViewModel(publisherBuiler: publisherBuiler))
        self.content = content
    }

    var body: some View {
        Group {
            DebugHelper.viewBodyPrint("View.body state = \(loadingVM.state)")
            switch loadingVM.state {
            case .idle:
                Color.clear
                    .onAppear(perform: loadingVM.load)
            case .loading:
                ProgressView()
            case .loaded:
                content(loadingVM.targetVM)
            case let .failure(error):
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