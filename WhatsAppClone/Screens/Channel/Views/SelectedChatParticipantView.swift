//
//  SelectedChatParticipantView.swift
//  WhatsAppClone
//
//  Created by Thomas on 11/06/24.
//

import SwiftUI

struct SelectedChatParticipantView: View {
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { item in
                    chatParticipantView(item)
                }
            }
        }
    }
    
    private func chatParticipantView(_ user: UserItem) -> some View {
        VStack {
            CircularProfileImageView(user.profileImageURL, size: .medium)
                .overlay(alignment: .topTrailing) {
                    cancelButton(user)
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton(_ user: UserItem) -> some View {
        Button {
            onTapHandler(user)
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
                .background(Color(.systemGray2))
                .clipShape(Circle())
        }
    }
}

#Preview {
    SelectedChatParticipantView(users: UserItem.placeholders) { user in
        
    }
}
