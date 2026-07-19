// Copyright © 2026 Pharos Solutions. All rights reserved.

import UIKit

final class CourseDetailsDataSource: NSObject, UITableViewDataSource {
    // MARK: - Properties

    weak var viewModel: CourseDetailsViewModel?

    // MARK: - Init

    init(viewModel: CourseDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel else { return 0 }
        switch viewModel.state.activeScreen {
        case .details:
            return viewModel.state.lessonsList.count
        case .materials:
            return viewModel.state.materialsDomain?.numberOfSections ?? 0
        case .reviews:
            return viewModel.state.reviewsList.isEmpty ? 0 : 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        switch viewModel.state.activeScreen {
        case .reviews:
            return viewModel.state.reviewsList.count
        case .details:
            return viewModel.numberOfRowsForLesson(section: section)
        case .materials:
            return viewModel.state.materialsDomain?.numberOfRows(in: section) ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel else { return UITableViewCell() }
        switch viewModel.state.activeScreen {
        case .details:
            let cell = tableView.dequeueCell(ofType: AttachmentTableViewCell.self, for: indexPath)
            let attachments = viewModel.attachmentsOfLessons(for: indexPath.section)
            if indexPath.row < attachments.count {
                cell?.configure(with: attachments[indexPath.row])
            }
            return cell ?? UITableViewCell()

        case .reviews:
            let cell = tableView.dequeueCell(ofType: ReviewTableViewCell.self, for: indexPath)
            cell?.configure(with: viewModel.state.reviewsList[indexPath.row])
            return cell ?? UITableViewCell()

        case .materials:
            let cell = tableView.dequeueCell(ofType: MaterialTableViewCell.self, for: indexPath)
            guard let item = viewModel.state.materialsDomain?.item(at: indexPath) else { return cell ?? UITableViewCell() }
            cell?.configure(with: MaterialTableCellData(
                title: item.displayTitle,
                date: item.displayDate,
                image: item.displayIcon,
                duration: item.displayDuration
            ))
            return cell ?? UITableViewCell()
        }
    }
}
