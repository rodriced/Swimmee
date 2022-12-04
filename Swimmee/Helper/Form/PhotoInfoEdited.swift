//
//  PhotoInfoEdited.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 29/11/2022.
//

import SwiftUI

public class PhotoInfoEdited {
    enum State: Equatable {
        case initial
        case removed
        case new(uiImage: UIImage, data: Data, size: Int, hash: Int)

        // Optimized comparison with only size and hash
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial), (.removed, .removed):
                return true
            case let (.new(uiImage: _, data: _, size: lsize, hash: lhash),
                      .new(uiImage: _, data: _, size: rsize, hash: rhash))
                     where lsize == rsize && lhash == rhash:
                return true
            default:
                return false
            }
        }
    }

    let initial: PhotoInfo?
    @Published private(set) var state = State.initial

    init(_ initialPhotoInfo: PhotoInfo?) {
        self.initial = initialPhotoInfo
    }

    func updateWith(uiImage: UIImage?) {
        guard let uiImage else {
            switch state {
            case .initial where initial == nil,
                 .removed:
                ()
            case .new where initial == nil:
                state = .initial
            default:
                state = .removed
            }
            return
        }

        do {
            let data = try ImageHelper.resizedImageData(from: uiImage)
            let newState = State.new(uiImage: uiImage, data: data, size: data.count, hash: data.hashValue)

            switch (newState, initial) {
            case let (.new(uiImage: _, data: _, size: size, hash: hash), .some(initial))
                where size == initial.size && hash == initial.hash:
                if state != .initial {
                    state = .initial
                }
            default:
                state = newState
            }

        } catch {
            print("ProfileViewModel.savePhoto (save) error \(error.localizedDescription)")
        }
    }

    func save(as uid: UserId) async -> PhotoInfo? {
        switch state {
        case .removed:
            do {
                try await API.shared.imageStorage.delete(uid)
            } catch {
                print("ProfileViewModel.savePhoto (delete) error \(error.localizedDescription)")
            }
            return nil

        case let .new(uiImage: _, data: photoData, size: _, hash: _):
            do {
                let photoUrl = try await API.shared.imageStorage.upload(uid, with: photoData)
                return PhotoInfo(url: photoUrl, data: photoData)
            } catch {
                print("ProfileViewModel.savePhoto (save) error \(error.localizedDescription)")
                return nil
            }
        case .initial:
            return nil
        }
    }
}
