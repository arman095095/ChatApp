//
//  Audio.swift
//  diffibleData
//
//  Created by Arman Davidoff on 05.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import AVFoundation
import MessageKit

/// The `PlayerState` indicates the current audio controller state
public enum PlayerState {
    case playing
    case pause
    case stopped
}

open class AudioMessagePlayer: NSObject {
    
    open var audioPlayer: AVAudioPlayer?
    open weak var playingCell: AudioMessageCell?
    open var playingMessage: MessageType?
    open private(set) var state: PlayerState = .stopped
    public weak var messageCollectionView: MessagesCollectionView?
    
    internal var progressTimer: Timer?
    
    // MARK: - Init Methods
    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }
    
    deinit {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = audioPlayer {
            playingCell = cell
            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
            cell.playButton.isSelected = (player.isPlaying == true) ? true : false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
        }
    }
    
    open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .custom(let kind):
            let audio = kind as! MessageKind
            switch audio {
            case .audio(let item):
                playingCell = audioCell
                playingMessage = message
                let url = FileManager.getDocumentsDirectory().appendingPathComponent(item.url.absoluteString)
                guard let player = try? AVAudioPlayer(contentsOf: url) else {
                    download(url: item.url, for: message, in: audioCell)
                    return
                }
                play(player: player, audioCell: audioCell, message: message)
            default:
                break
            }
        default:
            break
        }
    }
    
    private func download(url:URL,for message: MessageType, in audioCell: AudioMessageCell) {
        (audioCell as! AudioMessageCellCustom).activityIndicator.isHidden = false
        (audioCell as! AudioMessageCellCustom).activityIndicator.startLoading()
        FirebaseStorageManager.shared.downloadData(url: url) { [weak self] (result) in
            switch result {
            case .success(let data):
                let name = "\(UUID().uuidString).m4a"
                let newURL = FileManager.getDocumentsDirectory().appendingPathComponent(name)
                guard let _ = try? data.write(to: newURL) else { return }
                try! RealmManager.instance?.write { (message as! MMessage).audioURL = name }
                guard let player = try? AVAudioPlayer(contentsOf: newURL) else { return }
                self?.play(player: player, audioCell: audioCell, message: message)
                (audioCell as! AudioMessageCellCustom).activityIndicator.completeLoading(success: true)
                (audioCell as! AudioMessageCellCustom).activityIndicator.isHidden = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    open func play(player: AVAudioPlayer, audioCell: AudioMessageCell, message: MessageType) {
        audioPlayer = player
        audioPlayer?.prepareToPlay()
        audioPlayer?.delegate = self
        audioPlayer?.play()
        state = .playing
        audioCell.playButton.isSelected = true  // show pause button on audio cell
        startProgressTimer()
        audioCell.delegate?.didStartAudio(in: audioCell)
    }
    
    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }
    
    open func stopAnyOngoingPlaying() {
        guard let player = audioPlayer, let collectionView = messageCollectionView else { return }
        player.stop()
        state = .stopped
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer = nil
        playingMessage = nil
        playingCell = nil
    }
    
    open func resumeSound() {
        guard let player = audioPlayer, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        player.prepareToPlay()
        player.play()
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true // show pause button on audio cell
        cell.delegate?.didStartAudio(in: cell)
    }
    
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration - player.currentTime), for: cell, in: collectionView)
            } else {
                stopAnyOngoingPlaying()
            }
        }
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(AudioMessagePlayer.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.progressTimer = timer
        
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioMessagePlayer: AVAudioPlayerDelegate {
    
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAnyOngoingPlaying()
    }
    
    open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAnyOngoingPlaying()
    }
}
