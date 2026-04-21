// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.
import UIKit

class AppAlertViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var imageViewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var primaryButton: LoadingButton!
    @IBOutlet private var secondaryButton: LoadingButton!
    @IBOutlet private var closeButton: UIButton! {
        didSet {
            closeButton.isHidden = true
        }
    }

    // MARK: - Closures

    private var primaryAction: (() -> Void)?
    private var secondryAction: (() -> Void)?
    var notifyAlertHasBeenDismissed: (() -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewContainer.setFrameShape(.circular)
        primaryButton.layer.cornerRadius = UIConstants.cornerRadius
        primaryButton.backgroundColor = Asset.Colors.sendButtonColor.color
        primaryButton.isHidden = true
        secondaryButton.isHidden = true
        containerView.layer.cornerRadius = UIConstants.cornerRadius
    }

    // MARK: - Private functions

    private func handleCloseButtonAppearrance(shouldButtonAppear: Bool?) {
        if let shouldButtonAppear = shouldButtonAppear {
            closeButton.isHidden = shouldButtonAppear
        }
    }

    private func dismissViewController(completionHandler: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: true) {
            completionHandler?()
        }
    }

    // MARK: - Public functions

    func configure(
        image: UIImage?,
        title: String?,
        subtitle: String?,
        imageContainerColor: UIColor? = .groupTableViewBackground,
        shouldCloseButtonAppear: Bool? = nil
    ) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageViewContainer.backgroundColor = imageContainerColor
        handleCloseButtonAppearrance(shouldButtonAppear: shouldCloseButtonAppear)
    }

    func configureButtons(
        primaryButtonTitle: String,
        dismissButtonTitle: String,
        secondryButtonCompletionHandler: (() -> Void)? = nil,
        primaryButtonCompletionHandler: @escaping () -> Void
    ) {
        primaryButton.setTitle(primaryButtonTitle, for: .normal)
        secondaryButton.setTitle(dismissButtonTitle, for: .normal)
        primaryButton.isHidden = false
        secondaryButton.isHidden = false
        primaryAction = primaryButtonCompletionHandler
        secondryAction = secondryButtonCompletionHandler
    }

    func configureOneButton(buttonTitle: String, buttonCompletionHandler: @escaping () -> Void) {
        primaryButton.setTitle(buttonTitle)
        primaryButton.isHidden = false
        secondaryButton.isHidden = true
        primaryAction = buttonCompletionHandler
    }

    func configureOneButtonForDismiss(
        title: String = L10n.Shared.Action.dismiss,
        dismissAction: (() -> Void)? = nil
    ) {
        primaryButton.setTitle(title.localiz(), for: .normal)
        primaryButton.isHidden = false
        secondaryButton.isHidden = true
        primaryAction = dismissAction ?? { [weak self] in
            self?.dismissViewController { [weak self] in
                self?.notifyAlertHasBeenDismissed?()
            }
        }
    }

    func startPrimaryButtonLoading() {
        primaryButton.startLoading()
        secondaryButton.isUserInteractionEnabled = false
        secondaryButton.isEnabled = false
        closeButton.isUserInteractionEnabled = false
    }

    func startSecondaryButtonLoading() {
        secondaryButton.startLoading()
        primaryButton.isUserInteractionEnabled = false
        primaryButton.isEnabled = false
        closeButton.isUserInteractionEnabled = false
    }

    func stopPrimaryButtonLoading() {
        primaryButton.stopLoading()
        secondaryButton.isUserInteractionEnabled = true
        secondaryButton.isEnabled = true
        closeButton.isUserInteractionEnabled = true
    }

    func stopSecondaryButtonLoading() {
        secondaryButton.stopLoading()
    }
}

// MARK: - IBActions
extension AppAlertViewController {
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        dismissViewController { [weak self] in
            self?.notifyAlertHasBeenDismissed?()
        }
    }

    @IBAction private func didTapOnPrimaryButton(_ sender: Any) {
        primaryAction?()
    }

    @IBAction private func didTapOnSecondaryButton(_ sender: Any) {
        if secondryAction == nil {
            dismissViewController { [weak self] in
                self?.notifyAlertHasBeenDismissed?()
            }
        } else {
            secondryAction?()
        }
    }
}
