import UIKit

public class NoCutPasteTextField: UITextField {
    var isMandatoryTextField = Bool()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextFieldBehaviour()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureTextFieldBehaviour()
    }

    override public func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        if action == #selector(UIResponderStandardEditActions.paste(_:))
            ||
            action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return nil
        }
        return super.target(forAction: action, withSender: sender)
    }
}

extension NoCutPasteTextField {
    private func configureTextFieldBehaviour() {
        addTarget(self, action: #selector(setTextFieldBorder), for: .editingChanged)
    }

    @objc
    func setTextFieldBorder() {
        if let text = text, text.isEmpty, isMandatoryTextField {
            setErrorView()
        } else {
            setBorder(color: Asset.Colors.backgroundLightGreyColor.color, width: 1, cornerRadius: 6)
        }
    }

    func setErrorView() {
        setBorder(color: .red, width: 1, cornerRadius: 6)
    }
}
