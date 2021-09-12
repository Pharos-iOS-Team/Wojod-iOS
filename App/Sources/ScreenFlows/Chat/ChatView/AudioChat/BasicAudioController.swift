// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import MessageKit
import UIKit

enum PlayerState {
    case playing
    case pause
    case stopped
}

class BasicAudioController: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    weak var playingCell: AudioMessageCell?
    var playingMessage: MessageType?
    private(set) var state: PlayerState = .stopped
    weak var messageCollectionView: MessagesCollectionView?
    var progressTimer: Timer?

    // MARK: - Init Methods

    init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
        setupNotifications()
    }

    // MARK: - Methods
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
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
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pathComponentsCount = item.url.pathComponents.count
        let urlPathToSave = item.url.pathComponents[pathComponentsCount - 2] + item.url.pathComponents[pathComponentsCount - 1]
        let destinationURL = documentsPath.appendingPathComponent(urlPathToSave)
        if let fileLocalUrl = FileManager.default.localUrl(ofFileName: urlPathToSave) {
            handleDownloadingAudioSuccess(audioCell: audioCell, message: message, downloadedURL: fileLocalUrl, item: item, completion: completion)
        } else {
            downloadAudio(audioCell: audioCell, message: message, item: item, destinationUrl: destinationURL, completion: completion)
        }
    }

    private func downloadAudio(audioCell: AudioMessageCell, message: MessageType, item: AudioItem, destinationUrl: URL, completion: (() -> Void)? = nil) {
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: item.url) { [weak self] url, _, _ in
            if let url = url {
                DispatchQueue.main.sync {
                    self?.handleDownloadingAudioSuccess(audioCell: audioCell, message: message, downloadedURL: url, item: item, completion: completion)
                }
                do {
                    try? FileManager.default.removeItem(at: destinationUrl)
                    try FileManager.default.moveItem(at: url, to: destinationUrl)
                } catch {}
            }
        }
        downloadTask.resume()
    }

    private func handleDownloadingAudioSuccess(
        audioCell: AudioMessageCell,
        message: MessageType,
        downloadedURL: URL?,
        item: AudioItem,
        completion: (() -> Void)? = nil
    ) {
        playingCell = audioCell
        playingMessage = message
        guard let url = downloadedURL else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            state = .playing
            audioCell.playButton.isSelected = true
            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
            if let completion = completion { completion() }
        } catch {
            print(error)
        }
    }

    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    @objc
    func handleRouteChange(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        // Switch over the route change reason.
        switch reason {
        case .newDeviceAvailable:
            _ = AVAudioSession.sharedInstance()
        case .oldDeviceUnavailable:
            if (userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription) != nil {
            }
        default: ()
        }
    }

    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        return !routeDescription.outputs.filter{ $0.portType == .headphones }.isEmpty
    }

    func playSound(for message: MessageType, in audioCell: AudioMessageCell, completion: (() -> Void)? = nil) {
        switch message.kind {
        case .audio(let item):
            playSound(audioCell: audioCell, message: message, item: item, completion: completion)
        default:
            return
        }
    }

    func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false // show play button on audio cell
        progressTimer?.invalidate()
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    func stopAnyOngoingPlaying() {
        guard let player = audioPlayer,
        let collectionView = messageCollectionView
        else { return }
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
        dinitAudioPlayer()
    }

    func dinitAudioPlayer() {
        state = .stopped
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer = nil
        playingMessage = nil
        playingCell = nil
    }

    func resumeSound() {
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
    @objc
    private func didFireProgressTimer(_ timer: Timer) {
        guard let player = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            return
        }
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime / player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
            } else {
                stopAnyOngoingPlaying()
            }
        }
    }

    // MARK: - Private Methods
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(BasicAudioController.didFireProgressTimer(_:)),
            userInfo: nil,
            repeats: true
        )
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAnyOngoingPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stopAnyOngoingPlaying()
    }
}
