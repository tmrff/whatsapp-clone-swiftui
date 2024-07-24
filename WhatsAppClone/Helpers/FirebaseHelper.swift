//
//  FirebaseHelper.swift
//  WhatsAppClone
//
//  Created by Thomas on 19/06/2024.
//

import Foundation
import UIKit
import FirebaseStorage

typealias UploadCompletion = (Result<URL, Error>) -> Void
typealias ProgressHandler = (Double) -> Void

enum UploadError: Error {
    case failedToUploadImage(_ description: String)
    case failedToUploadFile(_ description: String)
}

extension UploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToUploadImage(let description), .failedToUploadFile(let description):
            return description
        }
    }
}

struct FirebaseHelper {
    
    static func uploadImage(
        _ image: UIImage,
        for type: UploadType,
        completion: @escaping UploadCompletion,
        progressHandler: @escaping ProgressHandler) {
            guard let imageDate = image.jpegData(compressionQuality: 0.5) else { return }
            
            let storageRef = type.filePath
            let uploadTask = storageRef.putData(imageDate) { _, error in
                if let error = error {
                    print("Failed to upload image to storage: \(error.localizedDescription)")
                    completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
                    return
                }
                
                storageRef.downloadURL(completion: completion)
            }
            
            uploadTask.observe(.progress) { snapshot in
                guard let progress = snapshot.progress else { return }
                let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
                progressHandler(percentage)
            }
        }
    
    static func uploadFile(for type: UploadType, fileURL: URL, completion: @escaping UploadCompletion, progressHandler: @escaping ProgressHandler) {
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: fileURL) { _, error in
            if let error = error {
                print("Failed to upload file to storage: \(error.localizedDescription)")
                completion(.failure(UploadError.failedToUploadFile(error.localizedDescription)))
                return
            }
            
            storageRef.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }
}

extension FirebaseHelper {
    enum UploadType {
        case profilePhoto
        case photoMessage
        case videoMessage
        case voiceMessage
        
        var filePath: StorageReference {
            let filename = UUID().uuidString
            switch self {
            case .profilePhoto:
                return FirebaseConstants.StorageRef.child("profile_photos").child(filename)
            case .photoMessage:
                return FirebaseConstants.StorageRef.child("photo_messages").child(filename)
            case .videoMessage:
                return FirebaseConstants.StorageRef.child("video_messages").child(filename)
            case .voiceMessage:
                return FirebaseConstants.StorageRef.child("voice_messages").child(filename)
            }
        }
    }
}
