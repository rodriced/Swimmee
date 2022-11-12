//
//  ViewLoader.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 27/10/2022.
//

import Combine
import SwiftUI

enum LoadingState<T> { case idle, loading, loaded(T), failure(String) }

protocol LoadableData: ObservableObject {
    associatedtype DataType
    var state: LoadingState<DataType> { get set }
    func load()
}

//extension LoadableData {
//    func reset() {state = .loading}
//}

class AsyncDataFromLoader<DataType>: LoadableData {
    @Published var state: LoadingState<DataType> = .idle

    var loader: () async throws -> DataType

    init(_ loader: @escaping () async throws -> DataType) {
        self.loader = loader
        debugPrint("---- AsyncDataLoadable created")
    }

    deinit {
        debugPrint("---- AsyncDataLoadable deinit")
    }

    func load() {
        debugPrint("---- AsyncDataLoadable load")

        state = .loading
        Task {
            do {
                let data = try await loader()
                await MainActor.run {
                    state = .loaded(data)
                }
            } catch {
                await MainActor.run {
                    state = .failure(error.localizedDescription)
                }
            }
        }
    }
}

class AsyncDataFromPublisher<DataType>: LoadableData {
    typealias DataPublisher = AnyPublisher<DataType, Error>

    @Published var state: LoadingState<DataType> = .idle

    var cancellable: AnyCancellable?
    var publisher: () -> DataPublisher

    init(_ publisher: @escaping () -> DataPublisher) {
        self.publisher = publisher
        debugPrint("---- PublishedAsyncData created")
    }

    deinit {
        debugPrint("---- PublishedAsyncData deinit")
    }

    func load() {
        debugPrint("---- PublishedAsyncData load")

        state = .loading

        cancellable = publisher()
//            .flatMap {
//                Just($0)
            .tryMap(LoadingState.loaded)
            .catch { error in
                Just(LoadingState.failure(error.localizedDescription))
            }
//            }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
    }
}

class AsyncDataFromPublisher2<DataType>: LoadableData {
    typealias DataPublisher = AnyPublisher<DataType, Error>
    typealias State = LoadingState<DataType>

    @Published var state: LoadingState<DataType> = .idle

    var cancellable: AnyCancellable?
    var statePublisher: AnyPublisher<State, Never>

    init(_ publisher: DataPublisher) {
        self.statePublisher =
        Just(LoadingState.idle)
            .append(Just(LoadingState.loading))
            .eraseToAnyPublisher()
        
//                publisher
//                    .tryMap(LoadingState.loaded)
//                    .catch { error in
//                        Just(LoadingState.failure(error.localizedDescription))
//                    }
//                    .receive(on: RunLoop.main)
//                    .eraseToAnyPublisher()
        
        debugPrint("---- PublishedAsyncData created")
    }

    deinit {
        debugPrint("---- PublishedAsyncData deinit")
    }

    func load() {
        debugPrint("---- PublishedAsyncData load")

//        state = .loading
//
//        cancellable = publisher()
////            .flatMap {
////                Just($0)
//            .tryMap(LoadingState.loaded)
//            .catch { error in
//                Just(LoadingState.failure(error.localizedDescription))
//            }
////            }
//            .receive(on: RunLoop.main)
//            .assign(to: \.state, on: self)
    }
}

struct ViewLoader<Source: LoadableData, Content: View>: View {
//    @StateObject var asyncData: AsyncDataLoadable<DataType>
//    @ObservedObject var asyncData: Source
    @StateObject var asyncData: Source
    private(set) var content: (Source.DataType) -> Content

    init(asyncData: Source, @ViewBuilder content: @escaping (Source.DataType) -> Content) {
//        _asyncData = StateObject(wrappedValue: AsyncDataLoadable(loadData: loadData))
//        _asyncData = ObservedObject(wrappedValue: AsyncDataFromLoader(loadData: loadData))
//        self.asyncData = asyncData
        self._asyncData = StateObject(wrappedValue: asyncData)
        self.content = content

        debugPrint("---- ViewLoader created")
    }
    
//    init(loader: @escaping () async throws -> Source.DataType, @ViewBuilder content: @escaping (Source.DataType) -> Content) {
//        self.asyncData = AsyncDataFromLoader(loader)
//        self.content = content
//    }
//
//    init(publisher: AnyPublisher<Source.DataType, Error>, @ViewBuilder content: @escaping (Source.DataType) -> Content) {
//        self.asyncData = AsyncDataFromPublisher(publisher) as! Source
//        self.content = content
//    }

    var body: some View {
        Group {
            DebugHelper.viewBodyPrint("ViewLoader.body state = \(asyncData.state)")
            switch asyncData.state {
            case .idle:
//                EmptyView()
                Color.clear
//                    .onAppear { asyncData.load() }
            case .loading:
                ProgressView()
            case .loaded(let data):
                content(data)
            case .failure(let errorMsg):
                Text("\(errorMsg)\nVerify your connectivity\nand come back on this page.")
            }
        }
//        .onAppear {
////            asyncData.state = .loading
//            asyncData.load()
//        }
        .task {
            asyncData.load()
        }
    }
}


protocol ViewModel {
    associatedtype Input
    init(input: Input)
}

class AsyncViewModele<VM: ViewModel>: LoadableData {
    @Published var state: LoadingState<VM> = .loading

    var loadData: () async throws -> VM

    init(loadData: @escaping () async throws -> VM) {
        self.loadData = loadData
        debugPrint("---- AsyncDataLoadable created")
    }

    deinit {
        debugPrint("---- AsyncDataLoadable deinit")
    }

    func load() {
        debugPrint("---- AsyncDataLoadable load")

        state = .loading
        Task {
            do {
                let data = try await loadData()
                await MainActor.run {
                    state = .loaded(data)
                }
            } catch {
                await MainActor.run {
                    state = .failure(error.localizedDescription)
                }
            }
        }
    }
}


struct ViewLoader2<DataType, Content: View>: View {
//    @StateObject var asyncData: AsyncDataLoadable<DataType>
    @ObservedObject var asyncData: AsyncDataFromLoader<DataType>
    private(set) var content: (DataType) -> Content

    init(loader: @escaping () async throws -> DataType, @ViewBuilder content: @escaping (DataType) -> Content) {
//        _asyncData = StateObject(wrappedValue: AsyncDataLoadable(loadData: loadData))
        _asyncData = ObservedObject(wrappedValue: AsyncDataFromLoader(loader))
        self.content = content

        debugPrint("---- ViewLoader2 created")
    }

    var body: some View {
        Group {
            switch asyncData.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView().onAppear { asyncData.load() }
            case .loaded(let data):
                content(data)
            case .failure(let errorMsg):
                Text("\(errorMsg)\nVerify your connectivity\nand come back on this page.")
            }
        }
    }
}

class ViewLoader1ViewModel<T, Content: View>: ObservableObject {
    private(set) var loadData: () async throws -> T
    private(set) var content: (T) -> Content

    enum LoadingState { case loading, loaded(T), failure(String) }
    @Published private(set) var loadingState = LoadingState.loading

    init(loadData: @escaping () async throws -> T,
         @ViewBuilder content: @escaping (T) -> Content)
    {
        self.loadData = loadData
        self.content = content
        debugPrint("---- ViewLoaderViewModel created")
    }

    func load() {
        loadingState = .loading
        Task {
            do {
                let data = try await loadData()
                await MainActor.run {
                    loadingState = .loaded(data)
                }
            } catch {
                await MainActor.run {
                    loadingState = .failure(error.localizedDescription)
                }
            }
        }
    }
}

struct ViewLoader1<T, Content: View>: View {
    @ObservedObject var viewModel: ViewLoader1ViewModel<T, Content>

    init(loadData: @escaping () async throws -> T, content: @escaping (T) -> Content) {
        viewModel = ViewLoader1ViewModel(loadData: loadData, content: content)
        debugPrint("---- ViewLoader created")
    }

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                ProgressView().onAppear { viewModel.load() }
            case .loaded(let data):
                viewModel.content(data)
            case .failure(let errorMsg):
                Text("\(errorMsg)\nVerify your connectivity\nand come back on this page.")
            }
        }
    }
}
