// Copyright © 2021 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import HandyUIKit
import LanguageManager_iOS

class TeacherCommentHeaderTableViewCell: UITableViewCell, NibLoadable {
    var deleteCommentHandler: (() -> Void)?
    var editCommentHandler: (() -> Void)?

    @IBOutlet private var headerTextLbl: UILabel!
    @IBOutlet private var editButton: LoadingButton!
    @IBOutlet private var removeButton: LoadingButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setText()
    }

    @IBAction private func editComment() {
        editCommentHandler?()
    }

    @IBAction private func deleteComment() {
        deleteCommentHandler?()
    }

    private func setText() {
        headerTextLbl.text = "homework.yourComment".localiz()
        headerTextLbl.textAlignment = Language.textAlignment
    }

    func setActionsApperance(shouldHide: Bool) {
        editButton.isHidden = shouldHide
        removeButton.isHidden = shouldHide
    }

    func startLoadingDeleteButton() {
        removeButton.startLoading()
    }

    func startLoadingEditButton() {
        editButton.startLoading()
    }
}
