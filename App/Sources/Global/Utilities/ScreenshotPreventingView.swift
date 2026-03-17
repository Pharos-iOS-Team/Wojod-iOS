// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SwiftUI
import UIKit

public final class ScreenshotPreventingView: UIView {
    // MARK: - 📌 Constants
    // MARK: - 🔶 Properties

    public var preventScreenCapture = true {
        didSet {
            textField.isSecureTextEntry = preventScreenCapture
        }
    }

    /// Changing isUserInteractionEnabled value will also affect
    /// isUserInteractionEnabled value of hidden content container.
    ///
    /// To sync isUserInteractionEnabled value is to prevent a freeze bug
    /// that is going to happen if you add a scrollview inside `ScreenshotPreventingView`.
    public override var isUserInteractionEnabled: Bool {
        didSet {
            hiddenContentContainer?.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }

    private var contentView: UIView?
    private let textField = UITextField()

    private let recognizer = HiddenContainerRecognizer()
    private lazy var hiddenContentContainer: UIView? = try? recognizer.getHiddenContainer(from: textField)

    // MARK: - 🎨 Style
    // MARK: - 🧩 Subviews
    // MARK: - 👆 Actions
    // MARK: - 🔨 Initialization

    public init(contentView: UIView? = nil) {
        self.contentView = contentView
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 🖼 View Lifecycle

    // MARK: - 🏗 UI

    private func setupUI() {
        textField.backgroundColor = .clear
        textField.isUserInteractionEnabled = false

        guard let container = hiddenContentContainer else { return }

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        guard let contentView = contentView else { return }
        setup(contentView: contentView)

        DispatchQueue.main.async {
            // setting secure text entry in init block will fail
            // setting default value inside main thread
            self.preventScreenCapture = true
        }
    }

    // MARK: - 🚌 Public Methods

    public func setup(contentView: UIView) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView

        guard let container = hiddenContentContainer else { return }

        container.addSubview(contentView)
        container.isUserInteractionEnabled = isUserInteractionEnabled
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        bottomConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: container.topAnchor),
            bottomConstraint
        ])
    }

    // MARK: - 🔒 Private Methods

}

// MARK: - Window-Level Screenshot Protection

extension ScreenshotPreventingView {
    private static var secureField: UITextField?

    static func protect(window: UIWindow) {
        if let field = secureField {
            field.isSecureTextEntry = true
            return
        }

        let field = UITextField()
        field.isUserInteractionEnabled = false
        field.backgroundColor = .clear

        window.addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            field.widthAnchor.constraint(equalToConstant: 0),
            field.heightAnchor.constraint(equalToConstant: 0)
        ])

        let recognizer = HiddenContainerRecognizer()
        guard let canvasView = try? recognizer.getHiddenContainer(from: field) else { return }
        window.layer.superlayer?.addSublayer(field.layer)
        canvasView.layer.addSublayer(window.layer)

        secureField = field

        DispatchQueue.main.async {
            field.isSecureTextEntry = true
        }
    }

    static func unprotect(window: UIWindow) {
        secureField?.isSecureTextEntry = false
    }
}

// MARK: - 🧶 Extensions

/// Beware that if you add view to subview that has been pulled out from this recognizer,
/// calling getter will result in nil value.
struct HiddenContainerRecognizer {
    private enum Error: Swift.Error {
        case unsupportedOSVersion(version: Float)
        case desiredContainerNotFound(_ containerName: String)
    }

    func getHiddenContainer(from view: UIView) throws -> UIView {
        let containerName = try getHiddenContainerTypeInStringRepresentation()
        let containers = view.subviews.filter { subview in
            type(of: subview).description() == containerName
        }

        guard let container = containers.first else {
            throw Error.desiredContainerNotFound(containerName)
        }

        return container
    }

    private func getHiddenContainerTypeInStringRepresentation() throws -> String {
        if #available(iOS 15, *) {
            return "_UITextLayoutCanvasView"
        }

        if #available(iOS 14, *) {
            return "_UITextFieldCanvasView"
        }

        if #available(iOS 13, *) {
            return "_UITextFieldCanvasView"
        }

        if #available(iOS 12, *) {
            return "_UITextFieldContentView"
        }

        let currentIOSVersion = (UIDevice.current.systemVersion as NSString).floatValue
        throw Error.unsupportedOSVersion(version: currentIOSVersion)
    }
}
