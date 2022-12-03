//
//  Helpers.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 09/11/2022.
//

import Combine
import Foundation
import XCTest

class SwimmeeUnitTesting {}

extension XCTestCase
{
    func publisherExpectation<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValue: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCTestExpectation
        where P.Output == Value, P.Failure == Never
    {
        let expectation = expectation(
            description: "Awaiting value \(expectedValue)"
        )

        var cancellable: AnyCancellable?

        cancellable = publisher
            .sink
            { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                cancellable?.cancel()
                expectation.fulfill()
            }

        return expectation
    }

    func publisherExpectation<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCTestExpectation
        where P.Output == Value, P.Failure == Never
    {
        var expectedValues = expectedValues

        let expectation = expectation(
            description: "Awaiting values \(expectedValues)"
        )

        var cancellable: AnyCancellable?

        cancellable = publisher
            .sink
            { value in
                let expectedValue = expectedValues.removeFirst()
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                if expectedValues.isEmpty
                {
                    cancellable?.cancel()
                    expectation.fulfill()
                }
            }

        return expectation
    }

    func assertPublishedValue<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValue: Value,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
        let publisher = publisher
            .dropFirst()
            .first(where: { $0 == expectedValue })

        let expectation = publisherExpectation(publisher, equals: expectedValue, file: file, line: line)

        action?()

        wait(for: [expectation], timeout: timeout)
    }

    func assertPublishedValues<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
        let expectation = publisherExpectation(publisher, equals: expectedValues)

        action?()

        wait(for: [expectation], timeout: timeout)
    }
}

// protocol HiddenTypeProtocol
// {
//    init?<T: Equatable>(_ value: T)
// }
//
//
// enum HiddenTypeSample: Equatable, HiddenTypeProtocol
// {
//    case int(Int)
//    case string(String)
//    case bool(Bool)
//
//    init?<T: Equatable>(_ value: T)
//    {
//        switch value.self
//        {
//        case let v as Int:
//            self = .int(v)
//        case let v as String:
//            self = .string(v)
//        case let v as Bool:
//            self = .bool(v)
//        default:
//            return nil
//        }
//    }
// }
//
// extension Publishers
// {
//    struct HideType<Upstream: Publisher, HiddenType: HiddenTypeProtocol>: Publisher
//        where Upstream.Output: Equatable, Upstream.Failure == Never
////    struct ErasedTypeP<Upstream: Publisher, UpstreamOutput: Equatable>: Publisher
////    where Upstream.Output == UpstreamOutput
//    {
//        typealias Output = HiddenType
//        typealias Failure = Never
//
//        let upstream: Upstream
//
//        func receive<S>(subscriber: S)
//            where S: Subscriber, Never == S.Failure, HiddenType == S.Input
//        {
//            upstream.map { HiddenType($0)! }.receive(subscriber: subscriber)
//        }
//    }
// }
//
// extension Publisher {
//    func hideType<P: Publisher>() -> P where P.Output == HiddenTypeProtocol, P.Failure == Never {
//        Publishers.HideType(upstream: self)
//    }
// }
