// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ChatContainerViewController: UIViewController {
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var receiverNameLbl: UILabel!
    @IBOutlet private var chatView: UIView!
    @IBOutlet private var endChatView: UIView!
    @IBOutlet private var endChatLabel: UILabel!
    @IBOutlet private var backButton: UIButton! {
        didSet {
            backButton.setImage(Asset.Images.localizedBackButton)
        }
    }
    var chatType: ChatType = .customerSupport

    private let activityIndicator = ActivityIndicator()
    private let chatViewCtrl = ChatViewController()
    private let viewModel = ChatContainerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChatChildVc()
        bindViewModel()
        setupEndChatbutton()
    }

    @IBAction private func closeBtn() {
        dismiss(animated: true)
    }

    @IBAction private func endChatButton() {
        activityIndicator.displayForLoading(in: view)
        viewModel.endChat()
    }

    private func setupEndChatbutton() {
        endChatLabel.text = L10n.Chat.endChat
        endChatView.layer.cornerRadius = 8
        endChatView.isHidden = true
    }

    private func bindViewModel() {
        viewModel.handleEndingChat = {
            self.activityIndicator.dismiss()
            self.dismiss(animated: true)
        }
    }

    private func addChatChildVc() {
        chatViewCtrl.setHeaderHandler = { name, conversationID in
            self.receiverNameLbl.text = name ?? ""
            self.endChatView.isHidden = (conversationID == nil || self.chatType != .customerSupport)
            self.viewModel.conversationID = conversationID
        }
        chatViewCtrl.chatType = chatType
        chatViewCtrl.willMove(toParent: self)
        addChild(chatViewCtrl)
        chatViewCtrl.didMove(toParent: self)
        chatView.addSubview(chatViewCtrl.view)
        chatViewCtrl.view.frame = chatView.bounds
    }
}
