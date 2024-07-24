//
//  SettingsTabViewModel.swift
//  WhatsAppClone
//
//  Created by Thomas on 23/07/2024.
//

import SwiftUI
import PhotosUI
import Combine
import Firebase
import AlertKit

@MainActor
final class SettingsTabViewModel: ObservableObject {
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var showProgressToast = false
    @Published var showSuccessToast = false
    
    private(set) var progressToastView = AlertAppleMusic17View(title: "Uploading Profile Photo", icon: .spinnerSmall)
    private(set) var successToastView = AlertAppleMusic17View(title: "Profile Info Updated", icon: .done)
    
    private var subscription: AnyCancellable?
    
    var disableSaveButton: Bool {
        return profilePhoto == nil
    }
    
    init() {
        onPhotoPickerSelection()
    }
    
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem = photoItem else { return }
                self?.parsePhotoPickerItem(photoItem)
            }
    }
    
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
        }
    }
    
    func uploadProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        showProgressToast = true
        FirebaseHelper.uploadImage(profilePhoto, for: .profilePhoto) { [weak self] result  in
            switch result {
            case.success(let imageUrl):
                self?.onUploadSuccess(imageUrl)
            case .failure(let error):
                print("Failed to upload profile image to firebase storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Uploading image progress: \(progress)")
        }
    }
    
    private func onUploadSuccess(_ imageUrl: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child(.profileImageURL).setValue(imageUrl.absoluteString)
        showProgressToast = false
        progressToastView.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showSuccessToast = true
            self.profilePhoto = nil
            self.selectedPhotoItem = nil
        }
        print("onUploadSuccess: \(imageUrl.absoluteString)")
    }
}
