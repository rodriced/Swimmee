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
    func injectLoadedData(_ loadedData: LoadedData)
}

protocol LoadableView: View {
    associatedtype ViewModel: LoadableViewModel
//    var vm: ViewModel {get set}
//    init(_ vm: ViewModel)
}

class LoadingViewModel<TargetViewModel: LoadableViewModel> : ObservableObject {
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

//    @Published var targetVM = CoachMessagesViewModel()
    let targetVM = TargetViewModel()

    var cancellable: Cancellable?

    func load() {
        print("ViewModel.load")

        state = .loading

        cancellable = publisherBuilder().asResult()
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

//        cancellable = API.shared.message.listPublisher()
        ////        cancellable = API.shared.message.listPublisherTest()
//            .sink { [weak self] result in
//                switch result {
//                case .success(let messages):
//                    self?.targetVM.messages = messages
//                    if self?.state != .loaded { self?.state = .loaded }
        ////                    state.assignIfNecessary(to: .loaded)
//
//                case .failure(let error):
//                    self?.state = .failure(error)
//                }
//            }
    }
}

struct LoadingView<TargetView: LoadableView>: View
{
    @StateObject var loadingVM: LoadingViewModel<TargetView.ViewModel>
    
    let content: (TargetView.ViewModel) -> TargetView

    init(publisherBuiler: @escaping () -> LoadingViewModel<TargetView.ViewModel>.LoadPublisher,
         content: @escaping (TargetView.ViewModel) -> TargetView) {
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
