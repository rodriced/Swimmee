//
//  CollectionCombineLatest.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 29/11/2022.
//

import Foundation
import Combine

extension Collection where Element: Publisher {
    func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
        var wrapped = map { $0.map { [$0] }.eraseToAnyPublisher() }
        while wrapped.count > 1 {
            wrapped = makeCombinedChunks(input: wrapped)
        }
        return wrapped.first?.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    }
}

private func makeCombinedChunks<Output, Failure: Swift.Error>(
    input: [AnyPublisher<[Output], Failure>]
) -> [AnyPublisher<[Output], Failure>] {
    sequence(
        state: input.makeIterator(),
        next: { it in it.next().map { ($0, it.next(), it.next(), it.next()) } }
    )
    .map { chunk in
        guard let second = chunk.1 else { return chunk.0 }

        guard let third = chunk.2 else {
            return chunk.0
                .combineLatest(second)
                .map { $0.0 + $0.1 }
                .eraseToAnyPublisher()
        }

        guard let fourth = chunk.3 else {
            return chunk.0
                .combineLatest(second, third)
                .map { $0.0 + $0.1 + $0.2 }
                .eraseToAnyPublisher()
        }

        return chunk.0
            .combineLatest(second, third, fourth)
            .map { $0.0 + $0.1 + $0.2 + $0.3 }
            .eraseToAnyPublisher()
    }
}
