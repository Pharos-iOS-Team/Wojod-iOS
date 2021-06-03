// Copyright © 2021 Pharos Solutions. All rights reserved.

import HandySwift
import UIKit

class NotificationsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var notificationsScreenTitleLabel: UILabel!

    // MARK: - Private Properties

    private var rowHeight: CGFloat = 100
    private var viewModel: NotificationsViewModel?
    private var notifications: [Notification] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NotificationsViewModel()
        configureTableView()
        loadNotifications()
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
            self.notifications = notifications
        }
    }
}

// MARK: - Table View Data Source

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(ofType: NotificationTableViewCell.self, for: indexPath) else { return UITableViewCell() }
        cell.configure(using: notifications[indexPath.row])
        return cell
    }
}

// MARK: - Table View Delegate

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}
