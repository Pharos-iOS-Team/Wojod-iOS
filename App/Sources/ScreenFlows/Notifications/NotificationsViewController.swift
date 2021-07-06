// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import JGProgressHUD
import UIKit

class NotificationsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var notificationsScreenTitleLabel: UILabel! {
        didSet {
            notificationsScreenTitleLabel.text = L10n.Notifications.title
        }
    }

    // MARK: - Private Properties

    private var rowHeight: CGFloat = 120
    private var viewModel: NotificationsViewModel?
    private var notifications: [Notification] = []
    private var documentInteractionController = UIDocumentInteractionController()
    private var loadingHud: JGProgressHUD?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NotificationsViewModel()
        configureTableView()
        loadNotifications()
        documentInteractionController.delegate = self
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Private functions

    private func configureTableView() {
        tableView.registerCell(ofType: NotificationTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func loadNotifications() {
        viewModel?.loadNotifications { notifications in
            self.notifications = notifications.notifications ?? []
            self.tableView.reloadData()
        }
    }

    private func storeAndShare(withURLString: String) {
        guard let url = URL(string: withURLString) else { return }
        showLoadingIndicator()
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                AlertHandler(presentingViewCtrl: self).showConfirmAlert(
                    title: L10n.Global.Titles.error,
                    message: L10n.Global.Alerts.somethingWentWrong
                )
            }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.share(url: tmpURL)
            }
        }.resume()
    }

    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }

    private func showLoadingIndicator() {
        loadingHud = JGProgressHUD()
        loadingHud?.textLabel.text = L10n.Global.Alerts.loading
        loadingHud?.show(in: self.view, animated: true)
    }

    private func hideLoadingIndicator() {
        loadingHud?.dismiss()
    }
}

// MARK: - Table View Data Source

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(ofType: NotificationTableViewCell.self, for: indexPath) else { return UITableViewCell() }
        cell.loadAttachmentsDelegate = self
        cell.configure(using: notifications[indexPath.row])
        return cell
    }
}

// MARK: - Table View Delegate

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Document Interaction Controller Delegate

extension NotificationsViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - Load Attachments Delegate

extension NotificationsViewController: LoadAttachmentDelegate {
    func loadAttachment(of url: String) {
        storeAndShare(withURLString: url)
    }
}
