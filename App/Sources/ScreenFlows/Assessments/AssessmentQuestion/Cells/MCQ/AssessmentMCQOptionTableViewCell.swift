//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import M13Checkbox

protocol PreviewQuestionImageDelegate: AnyObject {
    func previewImage(imageView: UIImageView, image: UIImage)
}

class AssessmentMCQOptionTableViewCell: UITableViewCell, UIDocumentInteractionControllerDelegate {
    @IBOutlet private var optionContainerView: UIView!
    @IBOutlet private var optionImageContainerView: UIView!
    @IBOutlet private var optionCheckBox: M13Checkbox!
    @IBOutlet private var wrongAnswerMark: UIImageView!
    @IBOutlet private var optionNameLabel: UILabel!
    @IBOutlet private var optionImageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var maximizeIconImageView: UIImageView!
    @IBOutlet private var optionImageHeight: NSLayoutConstraint!
    @IBOutlet private var optionImageWidth: NSLayoutConstraint!
    
    private var fetchedImage: UIImage?
    private var imageURL: URL?
    private weak var delegate: PreviewQuestionImageDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
        setQuestionImageHidden(true)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        wrongAnswerMark.isHidden = true
        maximizeIconImageView.isHidden = true
        optionImageView.image = nil
    }

    func configure(
        optionName: String,
        optionImageURL: String?,
        isSelected: Bool,
        textAlignment: NSTextAlignment,
        isCorrectAnswer: Bool?,
        isOpenAssessment: Bool,
        delegate: PreviewQuestionImageDelegate
    ) {
        optionContainerView.semanticContentAttribute = textAlignment == .left
            ? .forceLeftToRight
            : .forceRightToLeft
        optionNameLabel.textAlignment = textAlignment
        optionNameLabel.text = optionName
        optionCheckBox.setCheckState(
            isSelected
                ? .checked
                : .unchecked,
            animated: false
        )
        setOptionImage(optionImageURL)
        setCorrectAnswer(isCorrectAnswer)
        if isCorrectAnswer == true && isSelected {
            optionCheckBox.isHidden = false
        } else if !isOpenAssessment {
            optionCheckBox.isHidden = true
        }
        self.delegate = delegate
    }

    private func setCorrectAnswer(_ isCorrectAnswer: Bool?) {
        guard let isCorrectAnswer = isCorrectAnswer else {
            optionContainerView.backgroundColor = .white
            return
        }
        optionContainerView.backgroundColor = isCorrectAnswer
            ? Colors.green.color.withAlphaComponent(0.2)
            : UIColor.red.withAlphaComponent(0.1)
        optionCheckBox.setCheckState(
            isCorrectAnswer
                ? .checked
                : .unchecked,
            animated: false
        )
        optionCheckBox.tintColor = .white
        optionCheckBox.secondaryCheckmarkTintColor = Colors.green.color
        wrongAnswerMark.isHidden = isCorrectAnswer
    }

    private func setOptionImage(_ optionImageURL: String?) {
        guard let optionImageURL = optionImageURL,
            !optionImageURL.isEmpty,
            let imageURL = URL(string: "\(Environment.baseURL)\(optionImageURL)") else {
            setQuestionImageHidden(true)
            return
        }
        setQuestionImageHidden(false)
        activityIndicator.startAnimating()
        optionImageView.af_setImage(withURL: imageURL) { [weak self] _ in
            self?.activityIndicator.stopAnimating()
            self?.setImageAndTapGesture()
        }
    }
    
    private func setImageAndTapGesture() {
        maximizeIconImageView.isHidden = false
        optionImageView.isUserInteractionEnabled = true
        fetchedImage = optionImageView.image
        if fetchedImage == nil {
            maximizeIconImageView.isHidden = true
        }
        optionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage)))
    }
    
    @objc private func zoomImage() {
        guard let image = fetchedImage else { return }
        delegate?.previewImage(imageView: optionImageView, image: image )
    }
    
    private func setQuestionImageHidden(_ shouldHide: Bool) {
        optionImageHeight.constant = shouldHide ? 0 : 100
        optionImageWidth.constant = shouldHide ? 0 : 100
        layoutIfNeeded()
    }
    
    private func configureUI() {
        selectionStyle = .none
        optionImageContainerView.layer.cornerRadius = 10
        optionImageContainerView.addShadow(
            with: .lightGray,
            offset: CGSize(
                width: UIConstants.oneShadowWidth,
                height: UIConstants.oneShadowHeight
            ),
            radius: UIConstants.threeShadowRadius,
            opacity: Float(UIConstants.shadowOpacity)
        )
        optionImageView.contentMode = .scaleAspectFit
        optionContainerView.layer.cornerRadius = 10
        optionContainerView.layer.borderWidth = 1
        optionContainerView.layer.borderColor = Asset.Colors.sendButtonColor.color.cgColor.copy(alpha: 0.2)
        optionNameLabel.numberOfLines = 0
        optionNameLabel.lineBreakMode = .byWordWrapping
        optionNameLabel.font = UIFont(font: FontFamily.Inter.regular, size: 20)
        optionCheckBox.boxType = .circle
        optionCheckBox.markType = .checkmark
        optionCheckBox.stateChangeAnimation = .fill
        optionCheckBox.tintColor = Asset.Colors.sendButtonColor.color
    }
}
