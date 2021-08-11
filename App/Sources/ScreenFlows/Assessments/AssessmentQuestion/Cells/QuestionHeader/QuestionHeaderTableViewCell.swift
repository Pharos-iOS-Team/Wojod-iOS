//  Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import UIKit
import AlamofireImage

class QuestionHeaderTableViewCell: UITableViewCell {
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var questionImageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var maximizeImageView: UIImageView!
    @IBOutlet private var questionImageViewContainer: UIView!
    
    private weak var delegate: PreviewQuestionImageDelegate?
    private var questionImage: UIImage? {
        didSet {
            questionImageView.isUserInteractionEnabled = true
            questionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomImage)))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configure(
        questionTitle: String,
        hasImage: Bool,
        questionImage: UIImage?,
        textAlignment: NSTextAlignment,
        delegate: PreviewQuestionImageDelegate?
    ) {
        self.delegate = delegate
        questionLabel.textAlignment = textAlignment
        questionLabel.text = questionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        questionImageView.image = questionImage
        self.questionImage = questionImage
        
        (questionImage == nil && hasImage)
            ? activityIndicator.startAnimating()
            : activityIndicator.stopAnimating()
        checkForZoomAppearance(image: questionImage, hasImage: hasImage)
    }
    
    @objc private func zoomImage() {
        guard let image = questionImage else { return }
        delegate?.previewImage(imageView: questionImageView, image: image)
    }
    
    private func checkForZoomAppearance(image: UIImage?, hasImage: Bool) {
        maximizeImageView.isHidden = ((hasImage && image == nil) || !hasImage) ? true : false
    }
    
    private func configureUI() {
        selectionStyle = .none
        questionImageViewContainer.layer.cornerRadius = UIConstants.quizHeaderImageCornerRadius
        questionImageViewContainer.addShadow(
            with: .lightGray,
            offset: CGSize(
                width: UIConstants.oneShadowWidth,
                height: UIConstants.oneShadowHeight
            ),
            radius: UIConstants.threeShadowRadius,
            opacity: Float(UIConstants.shadowOpacity)
        )
        questionImageView.contentMode = .scaleAspectFit
        questionImageView.layer.cornerRadius = UIConstants.quizHeaderImageCornerRadius
        maximizeImageView.layer.cornerRadius = UIConstants.quizHeaderImageCornerRadius
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.font = UIFont(font: FontFamily.Inter.black, size: 24)
    }
}
