// Copyright © 2021 Pharos Solutions. All rights reserved.

import MessageKit
import UIKit

extension ChatViewController: MessageCellDelegate {
    // MARK: - Audio Messages
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        .white
    }

    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message)
    }

    open func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            startPlayingAudio(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            resetLastClickedAudioCellToDefault()
            startPlayingAudio(for: message, in: cell)
        }
        lastAudioIndexPathClicked = indexPath
    }

    private func startPlayingAudio(for message: MessageType, in cell: AudioMessageCell) {
        cell.activityIndicatorView.startAnimating()
        cell.playButton.isHidden = true
        audioController.playSound(for: message, in: cell) {
            cell.activityIndicatorView.stopAnimating()
            cell.playButton.isHidden = false
        }
    }

    private func resetLastClickedAudioCellToDefault() {
        if let lastClickedIndexPath = lastAudioIndexPathClicked,
           let previousClickedMessage = messagesCollectionView.messagesDataSource?.messageForItem(at: lastClickedIndexPath, in: messagesCollectionView) {
            let previousClickedCell: AudioMessageCell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: lastClickedIndexPath)
            previousClickedCell.activityIndicatorView.stopAnimating()
            previousClickedCell.playButton.isHidden = false
            audioController.pauseSound(for: previousClickedMessage, in: previousClickedCell)
        }
    }
}
