//
//  CombineExtension.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 12/11/2022.
//

import Foundation
import Combine

extension Publisher {
    typealias AsResult = Result<Output, Failure>

//    func asResult<Downstream: Publisher<AsResult,Never>>() -> Downstream {
//        self.map {Result.success($0)}
//            .catch {Just(Result.failure($0))} as! Downstream
//    }
    func asResult() -> AnyPublisher<AsResult,Never> {
        self.map {Result.success($0)}
            .catch {Just(Result.failure($0))}
            .eraseToAnyPublisher()
    }
}
