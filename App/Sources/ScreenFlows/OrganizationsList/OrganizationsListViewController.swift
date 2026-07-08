// Copyright © 2022 Pharos Solutions. All rights reserved.

import DZNEmptyDataSet
import JGProgressHUD
import UIKit

class OrganizationsListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var titleLabel: UILabel!

    private var viewModel: OrganizationsListViewModel?
    private var loadingHud: JGProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = OrganizationsListViewModel()
        showLoadingIndicator()
        setViewControllerTitle()
        configureTableView()
        configureErrorHandler()
        fetchOrganizations()
    }

    @IBAction private func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }

    private func setViewControllerTitle() {
        titleLabel.text = L10n.Organizations.title
    }

    private func configureTableView() {
        tableView.registerCell(ofType: OrganizationsListTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }

    private func fetchOrganizations() {
        viewModel?.fetchOrganizations { _ in
            self.hideLoadingIndicator()
            self.tableView.reloadData()
        }
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }

    private func configureErrorHandler() {
        viewModel?.errorHandler = { [weak self] error in
            self?.hideLoadingIndicator()
            guard let self = self else { return }
            let alert = AlertHandler(presentingViewCtrl: self)
            alert.showInformationAlert(title: L10n.Global.Titles.error, message: error.message)
        }
    }

    private func applyForOrganization(organizationId: Int, indexPath: IndexPath) {
        guard let organizationName = viewModel?.organizations?[indexPath.row].name else { return }
        showAlert(
            imageName: Images.danger.name,
            title: L10n.CourseDetails.CancelBooking.messageTitle,
            message: L10n.Organizations.applyConfirmation(organizationName),
            primaryButtonTitle: L10n.Organizations.apply,
            dismissButtonTitle: L10n.Global.Actions.cancel
        ) {
            self.dismiss(animated: true) {
                self.showLoadingIndicator()
                self.viewModel?.registerForOrganization(organizationId: organizationId) { organization in
                    self.viewModel?.organizations?[indexPath.row].status = organization.status
                    self.hideLoadingIndicator()
                    let alert = AlertHandler(presentingViewCtrl: self)
                    alert.showInformationAlert(title: "", message: L10n.Organizations.applicationSuccessful)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension OrganizationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.organizations?.count ?? .zero
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(ofType: OrganizationsListTableViewCell.self, for: indexPath) else { return UITableViewCell() }
        guard let organization = viewModel?.organizations?[indexPath.row] else { return UITableViewCell() }
        let organizationDataModel = OrganizationCellDataModel(
            doesContainImage: organization.media?.fileUrl != nil,
            organizationImage: AppEnvironment.baseURL.appendingPathComponent(organization.media?.fileUrl ?? ""),
            organizationName: organization.name,
            organizationStatus: OrganizationStatus(rawValue: organization.status ?? "") ?? .notRegistered
        )
        cell.didApplyForOrganization = { [weak self] in
            self?.applyForOrganization(organizationId: self?.viewModel?.organizations?[indexPath.row].id ?? .zero, indexPath: indexPath)
        }
        cell.configure(organizationModel: organizationDataModel)
        return cell
    }
}

// MARK: - Table View Delegate

extension OrganizationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - DZN Empty State Data Source

extension OrganizationsListViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: L10n.Organizations.empty)
    }
}

// MARK: - DZN Empty State Delegate

extension OrganizationsListViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !(loadingHud?.isVisible ?? false) && ((viewModel?.organizations?.isEmpty ?? true))
    }
}
