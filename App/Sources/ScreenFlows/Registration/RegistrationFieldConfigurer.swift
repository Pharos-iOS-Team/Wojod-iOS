// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

enum RegistrationFieldConfigurer {
    static func configureMandatory(_ textField: NoCutPasteTextField, placeholder: String) {
        textField.isMandatoryTextField = true
        textField.placeholder = placeholder
        textField.semanticContentAttribute = Language.semanticContent
        textField.textAlignment = Language.textAlignment
        applyBaseStyle(textField)
        textField.setNormalView()
    }

    static func configureOptional(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.semanticContentAttribute = Language.semanticContent
        textField.textAlignment = Language.textAlignment
        applyBaseStyle(textField)
        textField.setBorder(color: Asset.Colors.backgroundLightGreyColor.color, width: 1, cornerRadius: 5)
    }

    static func configurePickerField(_ textField: NoCutPasteTextField, placeholder: String, picker: UIView) {
        textField.placeholder = placeholder
        textField.addRightIcon(Images.path.image, width: 10, height: 6)
        textField.inputView = picker
        textField.isMandatoryTextField = true
        textField.semanticContentAttribute = Language.semanticContent
        textField.textAlignment = Language.textAlignment
        applyBaseStyle(textField)
        textField.setNormalView()
    }

    static func configureUniField(_ textField: NoCutPasteTextField, placeholder: String, picker: UIView) {
        textField.placeholder = placeholder
        textField.isMandatoryTextField = true
        textField.semanticContentAttribute = Language.semanticContent
        textField.textAlignment = Language.textAlignment
        if AppEnvironment.shouldHideOrganizationAndSchool {
            textField.isEnabled = false
            applyBaseStyle(textField)
            textField.backgroundColor = .gray.withAlphaComponent(0.15)
            textField.setNormalView()
        } else {
            textField.addRightIcon(Images.path.image, width: 10, height: 6)
            textField.inputView = picker
            applyBaseStyle(textField)
            textField.setNormalView()
        }
    }

    private static func applyBaseStyle(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.font = .systemFont(ofSize: 14)
        textField.layer.masksToBounds = true
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftView = padding
        textField.leftViewMode = .always
    }
}
