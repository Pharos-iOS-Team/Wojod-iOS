// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ChatContainerViewController: UIViewController {
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var chatIDLbl: UILabel!
    @IBOutlet private var receiverNameLbl: UILabel!
    @IBOutlet private var chatView: UIView!

    private let chatViewCtrl = ChatViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChatChildVc()
    }

    @IBAction private func closeBtn() {
        dismiss(animated: true)
    }

    private func addChatChildVc() {
        chatViewCtrl.willMove(toParent: self)
        addChild(chatViewCtrl)
        chatViewCtrl.didMove(toParent: self)
        chatView.addSubview(chatViewCtrl.view)
        chatViewCtrl.view.frame = chatView.bounds
    }
}
