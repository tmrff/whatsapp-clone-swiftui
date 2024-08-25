//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Thomas on 9/06/24.
//

import SwiftUI
import CoreMedia

struct BubbleAudioView: View {
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    @State private var playbackState: VoiceMessagePlayer.PlaybackState = .stopped
    
    private let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double>
    @State private var playbackTime = "00:00"
    @State private var isDraggingSlider = false
    
    init(item: MessageItem) {
        self.item = item
        let audioDuration = item.audioDuration ?? 20
        self._sliderRange = State(wrappedValue: 0...audioDuration)
    }
    
    private var isCorrectVoiceMessage: Bool {
        return voiceMessagePlayer.currentURL?.absoluteString == item.audioURL
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            
            if item.showGroupParticipantInfo {
                CircularProfileImageView(item.sender?.profileImageURL, size: .mini)
                    .offset(y: 5)
            }
            
            if item.direction == .sent {
                timeStampTextView()
            }
            
            HStack {
                playButton()
                Slider(value: $sliderValue, in: sliderRange) { editing in
                    isDraggingSlider = editing
                    if !editing && isCorrectVoiceMessage {
                        voiceMessagePlayer.seek(to: sliderValue)
                    }
                }
                .tint(.gray)
                
                if playbackState == .stopped {
                    Text(item.audioDurationAsString)
                        .foregroundStyle(.gray)
                } else {
                    Text(playbackTime)
                        .foregroundStyle(.gray)
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            
            if item.direction == .received {
                timeStampTextView()
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
        .overlay(alignment: item.reactionAnchor) {
            MessageReactionView(message: item)
                .offset(x: item.showGroupParticipantInfo ? 50 : 0, y: 10)
        }
        .onReceive(voiceMessagePlayer.$playbackState) { state in
           observePlayerState(state)
        }
        .onReceive(voiceMessagePlayer.$currentTime) { currentTime in
            guard voiceMessagePlayer.currentURL?.absoluteString == item.audioURL else { return }
            listen(to: currentTime)
        }
    }
    
    private func playButton() -> some View {
        Button {
            handlePlayVoiceMessage()
        } label: {
            Image(systemName: playbackState.icon)
                .padding(10)
                .background(item.direction == .received ? .green :.white)
                .clipShape(Circle())
                .foregroundStyle(item.direction == .received ? .white :.black)
        }
    }
    
    private func timeStampTextView() -> some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

// MARK: VoiceMessagePlayer Playback States
extension BubbleAudioView {
    private func handlePlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioUrlString = item.audioURL, let voiceMessageUrl = URL(string: audioUrlString) else { return }
            voiceMessagePlayer.playVoiceMessage(from: voiceMessageUrl)
        } else {
            voiceMessagePlayer.pauseVoiceMessage()
        }
    }
    
    private func observePlayerState(_ state: VoiceMessagePlayer.PlaybackState) {
        switch state {
        case .stopped:
            playbackState = .stopped
            sliderValue = 0
        case .playing, .paused:
            if isCorrectVoiceMessage {
               playbackState = state
            }
        }
    }
    
    private func listen(to currentTime: CMTime) {
        guard !isDraggingSlider else { return }
        playbackTime = currentTime.seconds.formatElapsedTime
        sliderValue = currentTime.seconds
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)
    }
    .environmentObject(VoiceMessagePlayer())
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
