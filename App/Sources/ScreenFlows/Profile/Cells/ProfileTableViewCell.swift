// Copyright © 2021 Pharos Solutions. All rights reserved.

import PhoneNumberKit
import UIKit

struct ProfileTableViewCellDataModel {
    var text: String
    var items: [String]
    var indexPath: Int
    var fields: [ProfileFields]
    var fieldLabel: String
    var shouldDisableTextField: Bool
}

protocol ProfileTableViwCellProtocol: AnyObject {
    func didFieldChange(text: String, cell: UITableViewCell, field: ProfileFields?)
}

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet private var profileTextField: FormTextField! {
        didSet {
            profileTextField.delegate = self
            profileTextField.addTarget(self, action: #selector(textFieldDidChangeValue(_:)), for: .editingChanged)
        }
    }
    weak var delegate: ProfileTableViwCellProtocol?
    var items: [String]?
    var selectedItem: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileTextField.inputView = nil
        profileTextField.isHidden = false
    }

    func addPickerView(field: ProfileFields) {
        guard let profileTextField = profileTextField else { return }
        let inputView = PickerInputView<String>(height: 250)
        inputView.items = { return (self.items ?? []) }
        inputView.didSelectAtIndex = { index in profileTextField.text = self.items?[index]
            self.selectedItem = self.items?[index] ?? ""
        }
        inputView.text = { string in return string }
        profileTextField.inputView = inputView
        profileTextField.inputAccessoryView = AccessoryView(L10n.Profile.selectItem, doneTapped: {
            profileTextField.resignFirstResponder()
            self.delegate?.didFieldChange(text: self.selectedItem ?? "", cell: self, field: field)
        }
        )
    }

    func configure(
        dataModel: ProfileTableViewCellDataModel,
        delegate: ProfileTableViwCellProtocol?
    ) {
        profileTextField.text = dataModel.text
        profileTextField.isEnabled = dataModel.shouldDisableTextField
        profileTextField.backgroundColor = !dataModel.shouldDisableTextField ? .groupTableViewBackground : .white
        self.items = dataModel.items
        self.delegate = delegate
        profileTextField.labelText = dataModel.fieldLabel
        if dataModel.fields[dataModel.indexPath] == .academicType
            || dataModel.fields[dataModel.indexPath] == .batch
            || (dataModel.fields[dataModel.indexPath] == .division && AppEnvironment.appName != .royalMedicine)
            || (dataModel.fields[dataModel.indexPath] == .specialization && AppEnvironment.appName != .royalMedicine)
            || dataModel.fields[dataModel.indexPath] == .country
            || dataModel.fields[dataModel.indexPath] == .city {
            addPickerView(field: dataModel.fields[dataModel.indexPath])
        }
    }

    func configureDefaultSelectionForCity() {
        profileTextField.text = self.items?.first
    }

    // MARK: - Phone Display
    func configureAsPhoneInput(fieldLabel: String, phoneNumber: String, countryCode: String) {
        profileTextField.isHidden = false
        profileTextField.isEnabled = false
        profileTextField.backgroundColor = .white
        profileTextField.labelText = fieldLabel
        let displayNumber = PhoneNumberValidator.stripEgyptianLeadingZero(phoneNumber, countryCode: countryCode)
        let digits = countryCode.hasPrefix("+") ? String(countryCode.dropFirst()) : countryCode
        let regionCode = UInt64(digits).flatMap { PhoneNumberUtility().mainCountry(forCode: $0) }
            ?? PhoneNumberValidator.egyptRegionCode
        let flag = PhoneNumberValidator.flagEmoji(forRegionCode: regionCode)
        profileTextField.text = "\(flag) \(countryCode) \(displayNumber)"
    }
}

extension ProfileTableViewCell: UITextFieldDelegate {
    @objc
    private func textFieldDidChangeValue(_ textField: UITextField) {
        guard let text = textField.text else { return }
        delegate?.didFieldChange(text: text, cell: self, field: nil)
    }
}
