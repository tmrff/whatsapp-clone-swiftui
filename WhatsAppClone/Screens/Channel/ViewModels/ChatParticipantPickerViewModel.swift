//
//  ChatParticipantPickerViewModel.swift
//  WhatsAppClone
//
//  Created by Thomas on 10/06/24.
//

import Foundation
import Firebase
import Combine

enum ChannelCreationRoute {
    case groupParticipantPicker
    case setUpGroupChat
}

enum ChannelConstants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatParticipant
    case failedToCreateUniqueIds
}

@MainActor
final class ChatParticipantPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatParticipants = [UserItem]()
    @Published private(set) var users = [UserItem]()
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")
    private var subscription: AnyCancellable?
    
    private var lastCursor: String?
    private var currentUser: UserItem?
    
    var showSelectedUsers: Bool {
        return !selectedChatParticipants.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatParticipants.isEmpty
    }
    
    var isPaginatable: Bool {
        return !users.isEmpty
    }
    
    private var isDirectChannel: Bool {
        return selectedChatParticipants.count == 1
    }
    
    init() {
        listenForAuthState()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func listenForAuthState() {
        subscription = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            switch authState {
            case .loggedIn(let loggedInUser):
                self?.currentUser = loggedInUser
                Task { await self?.fetchUsers() }
            default:
                break
            }
        }
    }
    
    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            self.users.append(contentsOf: fetchedUsers)
            self.lastCursor = userNode.currentCursor
            print("lastCursor: \(lastCursor) \(users.count)")
        } catch {
            print("💿 Failed to fetch users in ChatParticipantPickerViewModel")
        }
    }
    
    func deselectAllChatParticipants() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedChatParticipants.removeAll()
        }
    }
    
    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            guard let index = selectedChatParticipants.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatParticipants.remove(at: index)
        } else {
            guard selectedChatParticipants.count < ChannelConstants.maxGroupParticipants else {
                let errorMessage = "Sorry, we only allow a maximum of \(ChannelConstants.maxGroupParticipants) in a group chat."
                showError(errorMessage)
                return
            }
            selectedChatParticipants.append(item)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatParticipants.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func createGroupChannel(_ groupName: String?, completion: @escaping(_ newChannel: ChannelItem) -> Void) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            showError("Sorry, something went wrong while trying to set up your group chat.")
            print("Failed to create a Group Channel \(error.localizedDescription)")
        }
    }
    
    func createDirectChannel(_ chatParticipant: UserItem, completion: @escaping(_ newChannel: ChannelItem) -> Void) {
        selectedChatParticipants.append(chatParticipant)
        Task {
            // if existing DM, get the channel
            if let channelId = await verifyIfDirectChannelExisits(with: chatParticipant.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                var channelDict = snapshot.value as! [String: Any]
                var directChannel = ChannelItem(channelDict)
                directChannel.members = selectedChatParticipants
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                completion(directChannel)
            } else {
                // create a new DM with the user
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let error):
                    showError("Sorry, something went wrong while trying to set up your chat.")
                    print("Failed to create a Direct Channel \(error.localizedDescription)")
                }
            }
        }
    }
    
    typealias Channeld = String
    private func verifyIfDirectChannelExisits(with chatPartnerId: String) async -> Channeld? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists()
        else { return nil }
        
        let directMessageDict = snapshot.value as! [String: Bool]
        let channelId = directMessageDict.compactMap { $0.key }.first
        return channelId
    }
    
    func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
    
    private func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatParticipants.isEmpty else { return .failure(ChannelCreationError.noChatParticipant) }
        
        guard let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
              let currentUid = Auth.auth().currentUser?.uid,
              let messageId = FirebaseConstants.MessagesRef.childByAutoId().key
        else { return .failure(ChannelCreationError.failedToCreateUniqueIds) }
        
        let timeStamp = Date().timeIntervalSince1970
        var membersUids = selectedChatParticipants.compactMap { $0.uid }
        membersUids.append(currentUid)
        
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        
        var channelDict: [String: Any] = [
            .id : channelId,
            .lastMessage: newChannelBroadcast,
            .lastMessageType: newChannelBroadcast,
            .creationDate: timeStamp,
            .lastMessageTimeStamp: timeStamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }
        
        let messageDict: [String: Any] = [.type: newChannelBroadcast, .timeStamp : timeStamp, .ownerUid : currentUid]
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.MessagesRef.child(channelId).child(messageId).setValue(messageDict)
        
        membersUids.forEach { userId in
            // keeping an index of the channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }
        
        // make sure that a direct channel is unique
        if isDirectChannel {
            let chatParticipant = selectedChatParticipants[0]
            FirebaseConstants.UserDirectChannels.child(currentUid).child(chatParticipant.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannels.child(chatParticipant.uid).child(currentUid).setValue([channelId: true])
        }
        
        var newChannelItem = ChannelItem(channelDict)
        newChannelItem.members = selectedChatParticipants
        if let currentUser {
            newChannelItem.members.append(currentUser)
        }
        return .success(newChannelItem)
    }
}
