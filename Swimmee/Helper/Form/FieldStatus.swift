//
//  FieldStatus.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 29/11/2022.
//

import Combine
import Foundation

// FieldStatus is a class which when associated with felds of form,
// permits to manage validation with publishers

class FieldStatus<Value: Equatable> {
    let valuePublisher: Published<Value>.Publisher
    let validate: (Value) -> Bool
    let compareWith: ((Value) -> Bool)?
    let initialValue: Value?
    let debounceDelay: RunLoop.SchedulerTimeType.Stride

    init(valuePublisher: Published<Value>.Publisher,
         validate: @escaping (Value) -> Bool = { _ in true },
         compareWith: ((Value) -> Bool)? = nil,
         initialValue: Value? = nil,
         debounceDelay: RunLoop.SchedulerTimeType.Stride = 0.5)
    {
        self.valuePublisher = valuePublisher
        self.validate = validate
        self.compareWith = compareWith
        self.initialValue = initialValue
        self.debounceDelay = debounceDelay
    }

    private func isModified(_ value: Value) -> Bool {
        if let compareWith {
            return compareWith(value)
        } else if let initialValue {
            return initialValue != value
        } else {
            return true
        }
    }

    private func isValidated(_ value: Value) -> Bool {
        validate(value)
    }

    lazy var publisher = valuePublisher
        .debounce(for: debounceDelay, scheduler: RunLoop.main)
        .multicast(subject: PassthroughSubject())

    lazy var modified = publisher.map(isModified).eraseToAnyPublisher()
    lazy var validated = publisher.map(isValidated).eraseToAnyPublisher()

    var cancellables = Set<AnyCancellable>()
}

class FormFields<Value: Equatable> {
    var fields: [FieldStatus<Value>] = []

    lazy var publishers = fields.map(\.publisher)
    lazy var modified = fields.map(\.modified).combineLatest()
        .map { $0.contains(true) }
    lazy var validated = fields.map(\.validated).combineLatest()
        .map { $0.allSatisfy { $0 } }

    lazy var readyToSubmitUpdate =
        Publishers.CombineLatest(modified, validated)
            .map { $0 == (true, true) }
}
