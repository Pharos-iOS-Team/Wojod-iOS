// Copyright © 2020 Pharos Solutions. All rights reserved.

import HandyUIKit
import SwiftEntryKit
import UIKit

enum AttachmentTag: CaseIterable {
    case photos
    case camera
    case files
    case cancel
}

class AttachmentTypeActionSheet: UIView, NibLoadable {
    @IBOutlet private var view: UIView!
    @IBOutlet private var imagesButton: UIButton!
    @IBOutlet private var cameraButton: UIButton!
    @IBOutlet private var filesButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    var photoTypeSelectionHandler: (() -> Void)?
    var fileTypeSelectionHandler: (() -> Void)?
    var cameraTypeSelectionHandler: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }

    private func initWithNib() {
        try? loadFromNib()
        setupLayout()
    }

    @IBAction private func selectRequestType(_ sender: UIButton) {
        let attachmentType = AttachmentTag.allCases[sender.tag]
        SwiftEntryKit.dismiss()
        switch attachmentType {
        case .photos:
            photoTypeSelectionHandler?()
        case .camera:
            cameraTypeSelectionHandler?()
        case .files:
            fileTypeSelectionHandler?()
        case .cancel:
            return
        }
    }

    func actionSheetAttributes() -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.positionConstraints = .fullWidth
        attributes.positionConstraints.verticalOffset = .zero
        attributes.positionConstraints.safeArea = .overridden
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        return attributes
    }

    private func setupLayout() {
        view.setTopCornerRadius(radius: 20)
        configureTexts()
    }

    private func configureTexts() {
        imagesButton.setTitle(L10n.Chat.images, for: .normal)
        cameraButton.setTitle(L10n.Chat.camera, for: .normal)
        filesButton.setTitle(L10n.Chat.files, for: .normal)
        cancelButton.setTitle(L10n.Shared.Action.cancel, for: .normal)
    }

    func display() {
        let attributes =
            actionSheetAttributes()
        SwiftEntryKit.display(entry: self, using: attributes)
    }
}
