//
//  NewGroupSetUpScreen.swift
//  WhatsAppClone
//
//  Created by Thomas on 11/06/24.
//

import SwiftUI

struct NewGroupSetUpScreen: View {
    @State private var channelName = ""
    @ObservedObject var viewModel: ChatParticipantPickerViewModel
    var onCreate: (_ newChannel: ChannelItem) -> Void
    
    var body: some View {
        List {
            Section {
                channelSetUpHeaderView()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatParticipantView(users: viewModel.selectedChatParticipants) { user in
                    viewModel.handleItemSelection(user)
                }
            } header: {
                
                let count = viewModel.selectedChatParticipants.count
                let maxCount = ChannelConstants.maxGroupParticipants
                Text("Participants: \(count) of \(maxCount)")
                    .bold()
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("New Group")
        .toolbar {
            trailNavItem()
        }
    }
    
    private func channelSetUpHeaderView() -> some View {
        HStack {
            profileImageView()
            
            TextField("",
                      text: $channelName,
                      prompt: Text("Group Name (optional)"),
                      axis: .vertical
            )
        }
    }
    
    private func profileImageView() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                if viewModel.isDirectChannel {
                    guard let chatPartner = viewModel.selectedChatParticipants.first else { return }
                    viewModel.createDirectChannel(chatPartner, completion: onCreate)
                } else {
                    viewModel.createGroupChannel(channelName, completion: onCreate)
                }
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetUpScreen(viewModel: ChatParticipantPickerViewModel()) { _ in
            
        }
    }
}
