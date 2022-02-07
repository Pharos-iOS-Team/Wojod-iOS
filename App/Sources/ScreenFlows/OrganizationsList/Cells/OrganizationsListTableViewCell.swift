// Copyright © 2022 Pharos Solutions. All rights reserved.

import UIKit

struct OrganizationCellDataModel {
    var doesContainImage: Bool
    var organizationImage: URL?
    var organizationName: String?
    var organizationStatus: OrganizationStatus
}

class OrganizationsListTableViewCell: UITableViewCell {
    @IBOutlet private var mainView: UIView!
    @IBOutlet private var organizationImageView: UIImageView!
    @IBOutlet private var organizationNameLabel: UILabel!
    @IBOutlet private var statusView: UIView!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var applyButton: UIButton!

    var didApplyForOrganization: (() -> Void)?

    @IBAction private func applyForOrganization(_ sender: Any) {
        didApplyForOrganization?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        makeImageViewCircular()
    }

    func configure(organizationModel: OrganizationCellDataModel) {
        setImageView(url: organizationModel.organizationImage, doesContainImage: organizationModel.doesContainImage)
        organizationNameLabel.text = organizationModel.organizationName
        statusLabel.text = organizationModel.organizationStatus.rawValue
        statusView.backgroundColor = configureStatusBackgroundColor(organizationModel.organizationStatus)
        statusView.isHidden = OrganizationStatus(rawValue: organizationModel.organizationStatus.rawValue) == .notRegistered
        applyButton.isHidden = organizationModel.organizationStatus != .notRegistered
    }

    private func configureStatusBackgroundColor(_ organizationStatus: OrganizationStatus) -> UIColor {
        switch organizationStatus {
        case .approved:
            return Colors.green.color
        case .pending:
            return Colors.orange.color
        case .declined:
            return Colors.errorAlertLabelColor.color
        default:
            return .clear
        }
    }

    private func makeImageViewCircular() {
        organizationImageView?.setFrameShape(.circular)
        organizationImageView.layer.masksToBounds = false
        organizationImageView.clipsToBounds = true
    }

    private func setImageView(url: URL?, doesContainImage: Bool) {
        organizationImageView.kf.setImage(with: url)
        if !doesContainImage {
            organizationImageView.image = Images.organizationsEmpty.image
        }
    }
}
