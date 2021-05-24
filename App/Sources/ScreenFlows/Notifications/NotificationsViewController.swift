// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class NotificationsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var notificationsScreenTitleLabel: UILabel!

    // MARK: - Private Properties

    private var rowHeight: CGFloat = 100

    // MARK: - Dummy data sources

    private var teacherNames: [String] = ["Malak", "Nada", "Mona"]
    private var timeStamps: [String] = ["12 mins", "23 Feb", "12 Mar"]
    private var contentOfCells: [String] = ["Sent a new message", "Shared a file", "Published a new course"]
    private var numberOfRows: Int = 3
    private var images: [UIImage]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: - IBActions

    @IBAction private func didTapOnBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Private functions

    private func configureTableView() {
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - Table View Data Source

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell")
        as? NotificationTableViewCell else { return UITableViewCell() }
        cell.setTeacherName(teacherNames[indexPath.row])
        cell.setTimeStamp(timeStamps[indexPath.row])
        cell.setNotificationContent(contentOfCells[indexPath.row])
        cell.setTeacherAvatar(Images.notificationAvatar.image)

        return cell
    }
}

// MARK: - Table View Delegate

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}
