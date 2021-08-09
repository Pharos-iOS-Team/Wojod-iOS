// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation
import UIKit

class AudioRecordingViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var timerContainerView: UIView!
    @IBOutlet private var timerLabel: UILabel!
    @IBOutlet private var recordingLabel: UILabel!
    @IBOutlet private var stopRecordingButton: UIButton!
    @IBOutlet private var sendButton: LoadingButton!

    private var canSendAudio = false
    private var audioRecorder: AVAudioRecorder!
    private var audioFilename: URL?
    private var isAudioRecordingGranted: Bool!
    private var timerCounter = 0
    private var timer = Timer()
    var viewModel: ChatViewModel?
    var handleSendingMessageSuccessfully: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDesign()
        startRecording()
    }

    @IBAction private func dismissRecordView() {
        self.handleSendingMessageSuccessfully?()
        self.dismiss(animated: true)
    }

    @IBAction private func stopRecording() {
        canSendAudio = true
        finishAudioRecording()
        stopTimer()
    }

    @IBAction private func sendRecord() {
        sendButton.startLoading()
        viewModel?.selectedFile = audioFilename
        viewModel?.sendMessage(text: "")
        viewModel?.handleSendingMessageSuccess = {
            self.handleSendingMessageSuccessfully?()
            self.dismiss(animated: true)
        }
    }

    private func configureDesign() {
        containerView.layer.cornerRadius = 10
        sendButton.layer.cornerRadius = 8
        timerContainerView.setBorder(color: Asset.Colors.lightAccentColor.color, width: 2, cornerRadius: timerContainerView.frame.height / 2)
        recordingLabel.text = L10n.Chat.recording
        sendButton.setTitle(L10n.Chat.send)
    }

    func startRecording() {
        self.isAudioRecordingGranted = true
        self.audioRecorderAction()
    }

    func audioRecorderAction() {
        if isAudioRecordingGranted {
            handleViewInRecordingState()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44_100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                ]
                audioFilename = getDocumentsDirectory().appendingPathComponent("audio.m4a")
                guard let audioFilename = audioFilename else { return }
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
            } catch let error {
                print("Error for audio record: \(error.localizedDescription)")
            }
        }
    }

    private func handleViewForReadyForSendCase() {
        stopRecordingButton.isHidden = true
        recordingLabel.isHidden = true
        sendButton.isHidden = false
    }

    func handleViewInRecordingState() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        stopRecordingButton.isHidden = false
        recordingLabel.isHidden = false
        sendButton.isHidden = true
    }

    private func stopTimer() {
        timer.invalidate()
    }

    @objc
    func update() {
        timerCounter += 1
        timerLabel.text = calculateTimeString(time: TimeInterval(timerCounter))
    }

    func calculateTimeString(time: TimeInterval) -> String {
        let prodMinutes = Int(time) / 60 % 60
        let prodSeconds = Int(time) % 60
        return String(format: "%02d:%02d", prodMinutes, prodSeconds)
    }

    func finishAudioRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    // MARK:- Audio recoder delegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        handleViewForReadyForSendCase()
    }
}
