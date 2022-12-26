//
//  PublisherExtension.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 12/11/2022.
//

import Combine
import Foundation

// Publisher.asResut is a publisher operator that transforms the upstream publisher
// to a new publisher with a Result as new output and Never as error

extension Publisher {
    typealias AsResult = Result<Output, Failure>

    func asResult() -> AnyPublisher<AsResult, Never> {
        self.map(Result.success)
            .catch { Just(Result.failure($0)) }
            .eraseToAnyPublisher()
    }
}

// Publisher.not is a publisher operator that inverts the upstream publisher boolean output

extension Publisher
    where Output == Bool
{
    func not() -> Publishers.Map<Self, Bool> {
        map { !$0 }
    }
}

// Publisher.equatableAssign is a publisher operator that is equivalent to assign operator
// but change the the destination published value only when it's new

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
