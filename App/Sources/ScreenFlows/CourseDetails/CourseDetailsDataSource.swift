// Copyright © 2026 Pharos Solutions. All rights reserved.

import Kingfisher
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
        switch viewModel.activeScreen {
        case .details:
            return viewModel.lessonsList.count
        case .materials:
            return MaterialsSections.allCases.count
        case .reviews:
            return viewModel.reviewsList.isEmpty ? 0 : 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        switch viewModel.activeScreen {
        case .reviews:
            return viewModel.reviewsList.count
        case .details:
            return viewModel.numberOfRowsForLesson(section: section)
        case .materials:
            switch MaterialsSections(rawValue: section) {
            case .assignments:
                return viewModel.materials?.assignments?.count ?? 0
            case .quizzes:
                return viewModel.materials?.quizzes?.count ?? 0
            case .videos:
                return viewModel.materials?.videos?.count ?? 0
            case .documents:
                return viewModel.materials?.documents?.count ?? 0
            default:
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel else { return UITableViewCell() }
        switch viewModel.activeScreen {
        case .details:
            let cell = tableView.dequeueCell(ofType: AttachmentTableViewCell.self, for: indexPath)
            let attachments = viewModel.flatAttachments(for: indexPath.section)
            if indexPath.row < attachments.count {
                configureLessonDetails(cell: cell, with: attachments[indexPath.row])
            }
            return cell ?? UITableViewCell()

        case .reviews:
            let cell = tableView.dequeueCell(ofType: ReviewTableViewCell.self, for: indexPath)
            let review = viewModel.reviewsList[indexPath.row]
            let date = DateFormatter.isoDateFormatter.date(from: review.createdAt ?? "")
            cell?.setTitle(review.title ?? "")
            cell?.setSubtitle("\(date?.formatDateToDateTimeString ?? "") \(L10n.CourseDetails.CourseReview.by) \(review.reviewer?.name ?? "")")
            cell?.setComment(review.comment ?? "")
            cell?.setRating(review.rating ?? 0.0)
            let avatarURLString = AppEnvironment.baseURLString + (review.reviewer?.avatar?.fileUrl ?? "")
            if let avatarURL = URL(string: avatarURLString) {
                KingfisherManager.shared.retrieveImage(with: avatarURL) { [weak cell] result in
                    DispatchQueue.main.async {
                        if case .success(let value) = result {
                            cell?.setAvatarImage(value.image)
                        }
                    }
                }
            }
            return cell ?? UITableViewCell()

        case .materials:
            let cell = tableView.dequeueCell(ofType: MaterialTableViewCell.self, for: indexPath)
            guard let materialsSection = MaterialsSections(rawValue: indexPath.section) else {
                return cell ?? UITableViewCell()
            }
            switch materialsSection {
            case .assignments:
                let assignment = viewModel.materials?.assignments?[indexPath.row]
                let date = assignment?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: assignment?.title,
                    date: date.formattedDateString,
                    image: Images.quiz.image
                )
            case .quizzes:
                let quiz = viewModel.materials?.quizzes?[indexPath.row]
                let date = quiz?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: quiz?.title,
                    date: date.formattedDateString,
                    image: Images.quiz.image
                )
            case .videos:
                let video = viewModel.materials?.videos?[indexPath.row]
                let date = video?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: video?.title,
                    date: date.formattedDateString,
                    image: ((video?.link?.isEmpty ?? true) || video?.link.isYouTubeLink == true)
                        ? Images.videoExtension.image
                        : Images.link.image,
                    duration: video?.duration
                )
            case .documents:
                let document = viewModel.materials?.documents?[indexPath.row]
                let date = document?.publishedAt ?? Date()
                cell?.model = MaterialTableCellData(
                    title: document?.title ?? document?.fileName,
                    date: date.formattedDateString,
                    image: correspondingImage(for: document)
                )
            }
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }
    }

    // MARK: - Cell Configuration Helpers

    private func configureLessonDetails(cell: AttachmentTableViewCell?, with attachment: Any) {
        if let assignment = attachment as? Assessment {
            cell?.setSubtitleLabel(assignment.title)
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let quiz = attachment as? Assessment {
            cell?.setSubtitleLabel(quiz.title)
            cell?.setAttachmentImageView(Images.quiz.image)
        } else if let video = attachment as? Video {
            cell?.setSubtitleLabel(video.title)
            cell?.setDuration(video.duration)
            cell?.setAvaliablity(video.daysRemaining)
            if (video.link?.isEmpty ?? true) || video.link.isYouTubeLink {
                cell?.setAttachmentImageView(Images.videoExtension.image)
            } else {
                cell?.setAttachmentImageView(Images.link.image)
            }
        } else if let document = attachment as? Attachment {
            cell?.setSubtitleLabel((document.title ?? document.fileName) ?? "Document")
            cell?.setAttachmentImageView(correspondingImage(for: document))
        }
    }

    func correspondingImage(for document: Attachment?) -> UIImage {
        if let contentType = document?.mappedContentType {
            return contentType.icon
        }
        if document?.link.isYouTubeLink ?? false {
            return Images.videoExtension.image
        }
        if document?.link != nil {
            return Images.link.image
        }
        return Images.unknownExtension.image
    }
}
