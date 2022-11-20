//
//  FirestoreExtension.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 13/11/2022.
//

import Combine
import FirebaseFirestore

public extension Query
{
    // MARK: - Snapshot Publisher alternatives with better behaviour than the one from Firebase (see below)

    // The custom one is the chosen default

    /// Registers a publisher that publishes query snapshot changes.
    ///
    /// - Parameter includeMetadataChanges: Whether metadata-only changes (i.e. only
    ///   `QuerySnapshot.metadata` changed) should trigger snapshot events.
    /// - Returns: A publisher emitting `QuerySnapshot` instances.
    func snapshotPublisherCustom(includeMetadataChanges: Bool = false)
        -> AnyPublisher<QuerySnapshot, Error>
    {
        snapshotOnSubscriptionPublisher(includeMetadataChanges: includeMetadataChanges)
    }

    // MARK: - Snapshot Publisher 1 (snapshot listener is created on subscription and not at instanciation time)

    func snapshotOnSubscriptionPublisher(includeMetadataChanges: Bool = false)
        -> AnyPublisher<QuerySnapshot, Error>
    {
        let subject = PassthroughSubject<QuerySnapshot, Error>()

        var listenerHandle: ListenerRegistration?
        var isListenerEnabled = false // To indicate if we can create a new listener when request is received

        let newSnapshotListener = { [self] in
//            print("snapshotOnSubscriptionPublisher.newSnapshotListener")
            addSnapshotListener(includeMetadataChanges: includeMetadataChanges)
            { snapshot, error in
                if let error = error
                {
                    isListenerEnabled = false
                    subject.send(completion: .failure(error))
                }
                else if let snapshot = snapshot
                {
                    subject.send(snapshot)
                }
            }
        }

        let receiveSubscription: (Subscription) -> Void = { _ in
//            print("snapshotOnSubscriptionPublisher.receiveSubscription")
            guard !isListenerEnabled else { return }
            listenerHandle = newSnapshotListener()
            isListenerEnabled = true
        }

        let cancel = { [weak listenerHandle] in
//            print("snapshotOnSubscriptionPublisher.receivedCancel")
            listenerHandle?.remove()
            listenerHandle = nil
            isListenerEnabled = false
        }

        return subject
            .handleEvents(
                receiveSubscription: receiveSubscription,
                receiveCancel: cancel
            )
            .eraseToAnyPublisher()
    }

    // MARK: - Snapshot Publisher 2 (snapshot listener is created at instanciation time but the value is buffered for the first reauest)

    func snapshotBufferedPublisher(includeMetadataChanges: Bool = false)
        -> AnyPublisher<QuerySnapshot, Error>
    {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        var currentValue: QuerySnapshot?

        let listenerHandle =
            addSnapshotListener(includeMetadataChanges: includeMetadataChanges)
                { snapshot, error in
                    if let error = error
                    {
                        subject.send(completion: .failure(error))
                    }
                    else if let snapshot = snapshot
                    {
//                    print("snapshotBufferedPublisher : currentValue updated")
                        currentValue = snapshot
                        subject.send(snapshot)
                    }
                }

        return subject
            .handleEvents(
                receiveCancel: listenerHandle.remove,
                receiveRequest: { _ in
//                    print("snapshotBufferedPublisher.receivedRequest \(demand.description)")
                    guard let currentValue else { return }
                    subject.send(currentValue)
                }
            )
            .eraseToAnyPublisher()
    }
}
