//
//  SettingsTabScreen.swift
//  WhatsAppClone
//
//  Created by Thomas on 8/06/24.
//

import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    
    @State private var searchText = ""
    @StateObject private var viewModel = SettingsTabViewModel()
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
    }
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel: viewModel, currentUser)
                
                Section {
                    SettingsItemView(item: .broadCastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .alert(isPresent: $viewModel.showProgressToast, view: viewModel.progressToastView)
            .alert(isPresent: $viewModel.showSuccessToast, view: viewModel.successToastView)
        }
    }
}

extension SettingsTabScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Sign Out") {
                Task { try? await AuthManager.shared.logout() }
            }
            .foregroundStyle(.red)
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                viewModel.uploadProfilePhoto()
            }
            .bold()
            .disabled(viewModel.disableSaveButton)
        }
    }
}

private struct SettingsHeaderView: View {
    
    private let currentUser: UserItem
    @ObservedObject private var viewModel: SettingsTabViewModel
    
    init(viewModel: SettingsTabViewModel, _ currentUser: UserItem) {
        self.viewModel = viewModel
        self.currentUser = currentUser
    }
    
    var body: some View {
        Section {
            HStack {
                profileImageView()
                
                userInfoTextView()
            }
            
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .not(.videos)) {
                SettingsItemView(item: .avatar)
            }
        }
    }
    
    @ViewBuilder
    private func profileImageView() -> some View {
        if let profilePhoto = viewModel.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageURL, size: .custom(55))
        }
    }
    
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(currentUser.username)
                    .font(.title2)
                
                Spacer()
                
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text(currentUser.bioUnwrapped)
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabScreen(.placeholder)
}
