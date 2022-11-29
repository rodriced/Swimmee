//
//  CombineExtension.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 12/11/2022.
//

import Combine
import Foundation

extension Publisher {
    typealias AsResult = Result<Output, Failure>

    func asResult() -> AnyPublisher<AsResult, Never> {
        self.map(Result.success)
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }
}

extension Publisher
    where Output == Bool
{
    func not() -> Publishers.Map<Self, Bool> {
        map { !$0 }
    }
}

extension Publisher
    where Output: Equatable, Failure == Never
{
    func equatableAssign(to: inout Published<Output>.Publisher) {
        Publishers.CombineLatest(self, to)
            .filter { $0 != $1 }
            .map(\.0)
            .assign(to: &to)
    }

//    func equatableAssign(to: inout Published<Self.Output>.Publisher)
//        where Failure == Never, Output: Equatable
//    {
//        to.flatMap { presentValue in
//            self.map { newValue in
//                (presentValue, newValue)
//            }
//        }
//        .filter { $0 != $1 }
//        .map(\.1)
//        .assign(to: &to)
//    }
}

// extension Publisher {
//    func mapInner<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
//        self.map { sequence in
//            sequence.map(\.dbId)
//        }
//    }
//
//    func mapInner<TransformedOutput, T>(_ keyPath: KeyPath<Output.Element, T>) -> Publishers.Map<Self, TransformedOutput> where Output: Sequence, TransformedOutput: Sequence, TransformedOutput.Element == T {
//        self.map { sequence in
//            sequence.map { element in
//                element[keyPath: keyPath]
//            }
//        }
//    }
// }
