//
//  AuthProvider.swift
//  WhatsAppClone
//
//  Created by Thomas on 10/06/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
import StreamVideo

enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
}

protocol AuthProvider {
    static var shared: AuthProvider { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func autoLogin() async
    func login(with email: String, and password: String) async throws
    func createAccount(for username: String, with email: String, and password: String) async throws
    func logout() async throws
}

enum AuthError: Error {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfo(_ description: String)
    case emailLoginFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfo(let description):
            return description
        case .emailLoginFailed(let description):
            return description
        }
    }
}

final class AuthManager: AuthProvider {
    
    private init() {
        Task { await autoLogin() }
    }
    
    static var shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    @Published var streamVideo: StreamVideo?
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
           fetchCurrentUserInfo()
        }
    }
    
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
            print("🔐 Successfully Sign In : \(authResult.user.email ?? "") ")
        } catch {
            print("🔐 Failed to Sign Into the Account with: \(email)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoToDatabase(user: newUser)
            self.authState.send(.loggedIn(newUser))
        } catch {
            print("🔐 Failed to Create an Account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    func logout() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("🔐 Successfully logged out!")
        } catch {
            print("🔐 Failed to log out current User: \(error.localizedDescription)")
            throw AuthError.emailLoginFailed(error.localizedDescription)
        }
    }
}

extension AuthManager {
    private func saveUserInfoToDatabase(user: UserItem) async throws {
        do {
            let userDictionary: [String: Any] = [.uid : user.uid, .username : user.username, .email : user.email]
            try await FirebaseConstants.UserRef.child(user.uid).setValue(userDictionary)
        } catch {
            print("🔐 Failed to Save Created user Info to Databsse: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(error.localizedDescription)
        }
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedInUser = UserItem(dictionary: userDict)
            self?.authState.send(.loggedIn(loggedInUser))
            print("🔐 \(loggedInUser.username) is logged in")
            print("🔐 \(loggedInUser.username)'s fcm token is \(loggedInUser.fcmToken)")
        } withCancel: { error in
            print("Failed to get current user info")
        }
    }
}

extension AuthManager {
    private func setUpStreamVideo(for currentUser: UserItem) {
        let apiKey = "mmhfdzb5evj2"
        let user = User(id: "Grand_Moff_Tarkin", name: "Tarkin")
        let token = UserToken(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0dyYW5kX01vZmZfVGFya2luIiwidXNlcl9pZCI6IkdyYW5kX01vZmZfVGFya2luIiwidmFsaWRpdHlfaW5fc2Vjb25kcyI6NjA0ODAwLCJpYXQiOjE3MzA2MjQwNDUsImV4cCI6MTczMTIyODg0NX0.WaQqh76dzWFU7Vh6vyQu99g3ONAVcqv5VPdYYuWbstM")
        streamVideo = StreamVideo(apiKey: apiKey, user: user, token: token)
        print("🔐 Stream Video SDK SetUp Completed with user token: \(token)")
    }
}

extension AuthManager {
    
    static let testAccounts: [String] = [
        "QaUser1@test.com",
        "QaUser2@test.com",
        "QaUser3@test.com",
        "QaUser4@test.com",
        "QaUser5@test.com",
        "QaUser6@test.com",
        "QaUser7@test.com",
        "QaUser8@test.com",
        "QaUser9@test.com",
        "QaUser10@test.com",
        "QaUser11@test.com",
        "QaUser12@test.com",
        "QaUser13@test.com",
        "QaUser14@test.com",
        "QaUser15@test.com",
        "QaUser16@test.com",
        "QaUser17@test.com",
        "QaUser18@test.com",
        "QaUser19@test.com",
        "QaUser20@test.com",
        "QaUser21@test.com",
        "QaUser22@test.com",
        "QaUser23@test.com",
        "QaUser24@test.com",
        "QaUser25@test.com",
        "QaUser26@test.com",
        "QaUser27@test.com",
        "QaUser28@test.com",
        "QaUser29@test.com",
        "QaUser30@test.com",
        "QaUser31@test.com",
        "QaUser32@test.com",
        "QaUser33@test.com",
        "QaUser34@test.com",
        "QaUser35@test.com",
        "QaUser36@test.com",
        "QaUser37@test.com",
        "QaUser38@test.com",
        "QaUser39@test.com",
        "QaUser40@test.com",
        "QaUser41@test.com",
        "QaUser42@test.com",
        "QaUser43@test.com",
        "QaUser44@test.com",
        "QaUser45@test.com",
        "QaUser46@test.com",
        "QaUser47@test.com",
        "QaUser48@test.com",
        "QaUser49@test.com",
        "QaUser50@test.com",
    ]
}
