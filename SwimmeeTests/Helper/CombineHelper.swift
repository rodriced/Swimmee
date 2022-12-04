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
    ) -> (XCTestExpectation, AnyCancellable?)
        where P.Output == Value, P.Failure == Never
    {
        let expectation = expectation(
            description: "Awaiting value \(expectedValue)"
        )

        let cancellable = publisher
            .sink
            { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                expectation.fulfill()
            }

        return (expectation, cancellable)
    }
    
    func wait(
        for expectations: [(XCTestExpectation, AnyCancellable?)],
        timeout seconds: TimeInterval
    ) {
        wait(for: expectations.map(\.0), timeout: seconds)
        expectations.map(\.1).compactMap{$0}.forEach {
            $0.cancel()
        }
    }

    func publisherExpectation<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValue: Value,
        store: inout Set<AnyCancellable>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCTestExpectation
        where P.Output == Value, P.Failure == Never
    {
        let expectation = expectation(
            description: "Awaiting value \(expectedValue)"
        )

        publisher
            .sink
            { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                expectation.fulfill()
            }
            .store(in: &store)

        return expectation
    }

    func publisherExpectation<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        store: inout Set<AnyCancellable>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCTestExpectation
        where P.Output == Value, P.Failure == Never
    {
        var expectedValues = expectedValues

        let expectation = expectation(
            description: "Awaiting values \(expectedValues)"
        )

        publisher
            .sink
            { value in
                let expectedValue = expectedValues.removeFirst()
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                if expectedValues.isEmpty
                {
                    expectation.fulfill()
                }
            }
            .store(in: &store)

        return expectation
    }

    func assertPublishedValue<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValue: Value,
        store: inout Set<AnyCancellable>,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
//        let publisher = publisher
//            .dropFirst()
//            .first(where: { $0 == expectedValue })

        let expectation = publisherExpectation(publisher, equals: expectedValue, store: &store, file: file, line: line)

        action?()

        wait(for: [expectation], timeout: timeout)
    }

    func assertPublishedValues<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        store: inout Set<AnyCancellable>,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
        let expectation = publisherExpectation(publisher, equals: expectedValues, store: &store, file: file, line: line)

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
