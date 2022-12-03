//
//  FormField.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 29/11/2022.
//

import Foundation
import Combine

class FormField<Value: Equatable> {
    @Published var publishedValue: Value
    let validate: (Value) -> Bool
    let compareWith: ((Value) -> Bool)?
    let initialValue: Value?
    let debounceDelay: RunLoop.SchedulerTimeType.Stride

    init(publishedValue: inout Published<Value>,
         validate: @escaping (Value) -> Bool = { _ in true },
         compareWith: ((Value) -> Bool)? = nil,
         initialValue: Value? = nil,
         debounceDelay: RunLoop.SchedulerTimeType.Stride = 0.5)
    {
        _publishedValue = publishedValue
        self.validate = validate
        self.compareWith = compareWith
        self.initialValue = initialValue
        self.debounceDelay = debounceDelay
    }

    func isModified(_ value: Value) -> Bool {
        if let compareWith {
            return compareWith(value)
        } else if let initialValue {
            return initialValue != value
        } else {
            return true
        }
    }

    func isValidated(_ value: Value) -> Bool {
        validate(value)
    }

    lazy var publisher = $publishedValue
        .debounce(for: debounceDelay, scheduler: RunLoop.main)
        .multicast(subject: PassthroughSubject())

    lazy var modified = publisher.map(isModified).eraseToAnyPublisher()
    lazy var validated = publisher.map(isValidated).eraseToAnyPublisher()

    var cancellables = Set<AnyCancellable>()

//    func startPublishers() {
//        modified.sink {
//            print("FormField.modified = \($0)")
//        }
//        .store(in: &cancellables)
//
//        validated.sink {
//            print("FormField.validated = \($0)")
//        }
//        .store(in: &cancellables)
//
//        publisher.connect()
//            .store(in: &cancellables)
//    }
}

class FormFields<Value: Equatable> {
    var fields: [FormField<Value>] = []

    lazy var publishers = fields.map(\.publisher)
    lazy var modified = fields.map(\.modified).combineLatest()
        .map { $0.contains(true) }
    lazy var validated = fields.map(\.validated).combineLatest()
        .map { $0.allSatisfy { $0 } }

    lazy var readyToSubmitUpdate =
        Publishers.CombineLatest(modified, validated)
            .map { $0 == (true, true) }
}