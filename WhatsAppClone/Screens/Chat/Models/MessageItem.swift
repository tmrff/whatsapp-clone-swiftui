//
//  MessageItem.swift
//  WhatsAppClone
//
//  Created by Thomas on 8/06/24.
//

import SwiftUI
import Firebase

struct MessageItem: Identifiable {
    typealias userId = String
    typealias emoji = String
    typealias emojiCount = Int
    
    let id: String
    let isGroupChat: Bool
    let text: String
    let type: MessageType
    let ownerUid: String
    let timeStamp: Date
    var sender: UserItem?
    let thumbnailURL: String?
    var thumbnailHeight: CGFloat?
    var thumbnailWidth: CGFloat?
    var videoURL: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var reactions: [emoji: emojiCount] = [:]
    var userReactions: [userId: emoji] = [:]
    
    var direction: MessageDirection {
        return ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }
    
    static let sentPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Holy Spagetti", type: .text, ownerUid: "1", timeStamp: Date(), thumbnailURL: nil)
    static let receivedPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Hey", type: .text, ownerUid: "2", timeStamp: Date(), thumbnailURL: nil)
    
    var alignment: Alignment {
        return direction == . received ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        return direction == .received ? .leading : .trailing
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    var showGroupParticipantInfo: Bool {
        return isGroupChat && direction == .received
    }
    
    var leadingPadding: CGFloat {
        return direction == .received ? 0 : horizontalPadding
    }
    
    var trailingPadding: CGFloat {
        return direction == .received ? horizontalPadding : 0
    }
    
    private let horizontalPadding: CGFloat = 25
    
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    var imageWidth: CGFloat {
        let photoWidth = (UIWindowScene.current?.screenWidth ?? 0) / 1.5
        return photoWidth
    }
    
    var audioDurationAsString: String {
        return audioDuration?.formatElapsedTime ?? ""
    }
    
    var isSentByMe: Bool {
        return ownerUid == Auth.auth().currentUser?.uid ?? ""
    }
    
    var menuAnchor: UnitPoint {
        return direction == .received ? .leading : .trailing
    }
    
    var reactionAnchor: Alignment {
        return direction == .sent ? .bottomTrailing : .bottomLeading
    }
    
    var hasReactions: Bool {
        return !reactions.isEmpty
    }
    
    var currentUserHasReacted: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return userReactions.contains { $0.key == currentUid }
    }
    
    var currentUserReaction: String? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        return userReactions[currentUid]
    }
    
    func containsSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender, let userB = self.sender {
            return userA == userB
        } else {
            return false
        }
    }
    
    static let stubMessages: [MessageItem] = [
        .init(id: UUID().uuidString, isGroupChat: false, text: "Hi", type: .text, ownerUid: "3", timeStamp: Date(), thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: true, text: "Check this photo out", type: .photo, ownerUid: "4", timeStamp: Date(), thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: false, text: "Play this video", type: .video, ownerUid: "5", timeStamp: Date(), thumbnailURL: nil),
        .init(id: UUID().uuidString, isGroupChat: false, text: "", type: .audio, ownerUid: "6", timeStamp: Date(), thumbnailURL: nil)
    ]
}

extension MessageItem {
    init(id: String, isGroupChat: Bool, dict: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.ownerUid = dict[.ownerUid] as? String ?? ""
        let timeInterval = dict[.timeStamp] as? TimeInterval ?? 0
        self.timeStamp = Date(timeIntervalSince1970: timeInterval)
        self.thumbnailURL = dict[.thumbnailUrl] as? String ?? nil
        self.thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        self.thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        self.videoURL = dict[.videoURL] as? String? ?? nil
        self.audioURL = dict[.audioURL] as? String? ?? nil
        self.audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
        self.reactions = dict[.reactions] as? [emoji: emojiCount] ?? [:]
        self.userReactions = dict[.userReactions] as? [userId: emoji] ?? [:]
    }
}

extension String {
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
    static let reactions = "reactions"
    static let userReactions = "userReactions"
}
