//
//  MessageItem+Types.swift
//  WhatsAppClone
//
//  Created by Thomas on 14/06/24.
//

import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageType: Hashable {
    case admin(_ type: AdminMessageType), text, photo, video, audio
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "text":
            self = .text
        case "photo":
            self = .photo
        case "video":
            self = .video
        case "audio":
            self = .audio
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, .received].randomElement() ?? .sent
    }
}

extension MessageType: Equatable {
    static func ==(lhs: MessageType, rhs: MessageType) -> Bool {
        switch(lhs, rhs) {
            
        case (.admin(let leftAdmin), .admin(let rightAdmin)):
            return leftAdmin == rightAdmin
            
        case (.text, .text),
            (.photo, .photo),
            (.video, .video),
            (.audio, .audio):
            return true
            
        default:
            return false
        }
    }
}
