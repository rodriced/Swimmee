//
//  Helpers.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 09/11/2022.
//

import Combine
import Foundation
import XCTest

extension XCTestCase
{
    // 'publisherExpectation' create a special expectation for a publisher
    // that fullfill when a defined value is emited.
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

        var cancellable: AnyCancellable?

        cancellable = publisher
            .drop { $0 != expectedValue }
            .sink
            { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                cancellable?.cancel()
                expectation.fulfill()
            }

        return (expectation, cancellable)
    }

    // This other form of 'publisherExpectation' create a special expectation for a publisher
    // that fullfill when a defined sequence of values are emited.
    func publisherExpectation<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (XCTestExpectation, AnyCancellable?)
        where P.Output == Value, P.Failure == Never
    {
        var expectedValues = expectedValues

        let expectation = expectation(
            description: "Awaiting values \(expectedValues)"
        )

        let cancellable = publisher
            .drop { value in expectedValues.first.map { value != $0 } ?? true }
            .sink
            { value in
                let expectedValue = expectedValues.removeFirst()
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                if expectedValues.isEmpty
                {
                    expectation.fulfill()
                }
            }

        return (expectation, cancellable)
    }

    // This form of 'wait' function has the same behaviour as the standart one
    // but for an expectation created by 'publisherExpectation'
    func wait(
        for expectations: [(XCTestExpectation, AnyCancellable?)],
        timeout seconds: TimeInterval
    )
    {
        wait(for: expectations.map(\.0), timeout: seconds)
        expectations.map(\.1).compactMap { $0 }.forEach
        {
            $0.cancel()
        }
    }

    // 'assertPublishedValue' combine:
    // - a 'publisherExpectation' waiting for the emission of a value,
    // - the execution of some custom code,
    // - and a 'wait'
    func assertPublishedValue<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValue: Value,
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
        let expectation = publisherExpectation(publisher, equals: expectedValue, file: file, line: line)

        action?()

        wait(for: [expectation], timeout: timeout)
    }

    // this othe form of 'assertPublishedValue' combine:
    // - a 'publisherExpectation' waiting for the emission of a sequence of values,
    // - the execution of some custom code,
    // - and a 'wait'
    func assertPublishedValues<Value: Equatable, P: Publisher>(
        _ publisher: P,
        equals expectedValues: [Value],
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: UInt = #line,
        whenExecuting action: (() -> Void)?
    )
        where P.Output == Value, P.Failure == Never
    {
        let expectation = publisherExpectation(publisher, equals: expectedValues, file: file, line: line)

        action?()

        wait(for: [expectation], timeout: timeout)
    }
}
