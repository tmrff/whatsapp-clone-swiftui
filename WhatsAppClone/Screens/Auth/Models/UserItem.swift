//
//  UserItem.swift
//  WhatsAppClone
//
//  Created by Thomas on 10/06/24.
//

import Foundation

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    var username: String
    let email: String
    var bio: String?
    var profileImageURL: String? = nil
    var fcmToken: String?
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I am using WhatsApp."
    }
    
    static let placeholder = UserItem(uid: "1", username: "Steve", email: "bigsteve@gmail.com")
    
    static let placeholders: [UserItem] = [
        UserItem(uid: "1", username: "Steve", email: "bigsteve@gmail.com", bio: "I like eggs."),
        UserItem(uid: "2", username: "Dave", email: "dave@gmail.com"),
        UserItem(uid: "3", username: "Bob", email: "bob@gmail.com", bio: "My name is Bob."),
        UserItem(uid: "4", username: "Emma", email: "emma@gmail.com"),
        UserItem(uid: "5", username: "Shelley", email: "emma@gmail.com", bio: "I love Art."),
        UserItem(uid: "6", username: "Mike", email: "mike@gmail.com"),
        UserItem(uid: "7", username: "Jim", email: "jim@gmail.com", bio: "I eat food."),
        UserItem(uid: "8", username: "Slayer", email: "slayer@gmail.com"),
        UserItem(uid: "9", username: "Cool person 1", email: "coolperson@gmail.com", bio: "I am a cool person."),
        UserItem(uid: "10", username: "Vader", email: "vader@gmail.com")
    ]
}

extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String ?? nil
        self.profileImageURL = dictionary[.profileImageURL] as? String ?? nil
        self.fcmToken = dictionary[.fcmToken] as? String ?? nil
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageURL = "profileImageUrl"
    static let fcmToken = "fcmToken"
}
