//
//  ChannelItemView.swift
//  WhatsAppClone
//
//  Created by Thomas on 8/06/24.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: ChannelItem
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(channel, size: .medium)
            VStack(alignment: .leading, spacing: 3) {
                titleTextView()
                lastMessagePreview()
            }
            .overlay(alignment: .bottomTrailing) {
                if channel.unreadCount > 0 {
                    badgeView(count: channel.unreadCount)
                }
            }
        }
    }
    
    private func titleTextView() -> some View {
        HStack {
            Text(channel.title)
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text(channel.lastMessageTimeStamp.dayOrTimeRepresentation)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        HStack(spacing: 4) {
            if channel.lastMessageType != .text {
                Image(systemName: channel.lastMessageType.iconName)
                    .imageScale(.small)
                    .foregroundStyle(.gray)
            }
            
            Text(channel.previewMessage)
                .font(.system(size: 16))
                .lineLimit(2)
                .foregroundStyle(.gray)
        }
    }
    
    private func badgeView(count: Int) -> some View {
        Text(count.description)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.badge)
            .bold()
            .font(.caption)
            .clipShape(Capsule())
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
