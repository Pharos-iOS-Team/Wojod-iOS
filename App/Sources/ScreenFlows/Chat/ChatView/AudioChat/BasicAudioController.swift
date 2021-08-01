// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import MessageKit
import UIKit

enum PlayerState {
    case playing
    case pause
    case stopped
}

open class BasicAudioController: NSObject, AVAudioPlayerDelegate {
    open var audioPlayer: AVAudioPlayer?
    open weak var playingCell: AudioMessageCell?
    open var playingMessage: MessageType?
    private(set) var state: PlayerState = .stopped
    public weak var messageCollectionView: MessagesCollectionView?
    internal var progressTimer: Timer?

    // MARK: - Init Methods

    public init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    /// Used to configure the audio cell UI:
    ///     1. play button selected state;
    ///     2. progresssView progress;
    ///     3. durationLabel text;
    ///
    /// - Parameters:
    ///   - cell: The `AudioMessageCell` that needs to be configure.
    ///   - message: The `MessageType` that configures the cell.
    ///
    /// - Note:
    ///   This protocol method is called by MessageKit every time an audio cell needs to be configure
    open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = audioPlayer {
            playingCell = cell
            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime / player.duration)
            cell.playButton.isSelected = (player.isPlaying == true) ? true : false
            guard collectionView.messagesDisplayDelegate != nil else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.isHidden = true
            cell.durationLabel.text = ""
        }
    }

    private func playSound(audioCell: AudioMessageCell, message: MessageType, item: AudioItem, completion: (() -> Void)? = nil) {
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: item.url) { [weak self](url, response, error) -> Void in
            self?.playingCell = audioCell
            self?.playingMessage = message
            guard let url = url,
                  let player = try? AVAudioPlayer(contentsOf: url) else {
                print("Failed to create audio player for URL: \(item.url)")
                return
            }
            self?.audioPlayer = player
            self?.audioPlayer?.prepareToPlay()
            self?.audioPlayer?.delegate = self
            self?.audioPlayer?.play()
            self?.state = .playing
            DispatchQueue.main.sync {
                audioCell.playButton.isSelected = true
                self?.startProgressTimer()
                audioCell.delegate?.didStartAudio(in: audioCell)
                if let completion = completion {
                    completion()
                }
            }
        }
        downloadTask.resume()
    }

    open func playSound(for message: MessageType, in audioCell: AudioMessageCell, completion: (() -> Void)? = nil) {
        switch message.kind {
        case .audio(let item):
            playSound(audioCell: audioCell, message: message, item: item, completion: completion)
        default:
            print("BasicAudioPlayer failed play sound becasue given message kind is not Audio")
            return
        }
    }

    open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false // show play button on audio cell
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    open func stopAnyOngoingPlaying() {
        guard let player = audioPlayer,
              let collectionView = messageCollectionView
        else { return } // If the audio player is nil then we don't need to go through the stopping logic
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

    // MARK: - Fire Methods
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        // check if can update playing cell
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            // 1. get the current message that decorates the playing cell
            // 2. check if current message is the same with playing message, if so then update the cell content
            // Note: Those messages differ in the case of cell reuse
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                // messages are the same update cell content
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
            } else {
                // if the current message is not the same with playing message stop playing sound
                stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BasicAudioController.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
    }

    // MARK: - AVAudioPlayerDelegate
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAnyOngoingPlaying()
    }

    open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAnyOngoingPlaying()
    }
}
