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
            Image(systemName: channel.lastMessageType.iconName)
                .imageScale(.small)
                .foregroundStyle(.gray)
            
            Text(channel.previewMessage)
                .font(.system(size: 16))
                .lineLimit(2)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
