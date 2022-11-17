//
//  FirestoreCoachCollectionAPI.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 17/11/2022.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseFirestoreSwift
import Foundation

#if DEBUG
extension FirestoreCollectionAPI {
    //
    func listPublisherTest(owner: OwnerFilter = .currentUser, isSended: IsSendedFilter = .sended) -> AnyPublisher<Result<[Item], Error>, Never> {
        queryBy(owner: owner, isSended: isSended).snapshotPublisher()
            .tryMap { querySnapshot in
                if (0 ... 9).randomElement() ?? 0 < 4 { throw ListPublisherTestError() }
                return try querySnapshot.documents.map { document in
                    try document.data(as: Item.self)
                }
            }
            .asResult()
            .eraseToAnyPublisher()
    }
}
#endif
