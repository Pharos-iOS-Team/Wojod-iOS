// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

// MARK: - Row Selection

extension CourseDetailsViewController {
    func handleMaterialsSelection(at indexPath: IndexPath) {
        switch MaterialsSections(rawValue: indexPath.section) {
        case .videos:
            guard let video = viewModel.materials?.videos?[indexPath.row], !video.locked else {
                alertHandler.showInformationAlert(title: L10n.Global.Titles.warning, message: viewModel.materials?.videos?[indexPath.row].lockMessage ?? "")
                return
            }
            handleVideoSelection(video)

        case .documents:
            if let document = viewModel.materials?.documents?[indexPath.row] {
                handleDocumentSelection(document)
            }

        case .quizzes:
            let cell = tableView.cellForRow(at: indexPath) as? MaterialTableViewCell
            cell?.startLoadingIndicator()
            activeSubscreen = .quiz
            viewModel.quizzesViewModel.assessments = viewModel.materials?.quizzes ?? []
            viewModel.selectedAssessment = viewModel.materials?.quizzes?[indexPath.row]
            let quiz = viewModel.materials?.quizzes?[indexPath.row]
            switch quiz?.mappedStatus {
            case .open:
                viewModel.startAssessment(for: .quiz, at: indexPath) { cell?.stopLoadingIndicator() }
            case .closed:
                tableView.isUserInteractionEnabled = false
                viewModel.showResultForAssessment(type: quiz?.mappedType ?? .quiz, at: indexPath) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                    cell?.stopLoadingIndicator()
                }
            default:
                return
            }

        case .assignments:
            activeSubscreen = .exercise
            viewModel.assignmentsViewModel.assessments = viewModel.materials?.assignments ?? []
            viewModel.selectedAssessment = viewModel.materials?.assignments?[indexPath.row]
            let assignment = viewModel.materials?.assignments?[indexPath.row]
            switch assignment?.mappedStatus {
            case .open:
                viewModel.startAssessment(for: .assignment, at: indexPath) { }
            case .closed:
                tableView.isUserInteractionEnabled = false
                viewModel.showResultForAssessment(type: assignment?.mappedType ?? .assignment, at: indexPath) { [weak self] in
                    self?.tableView.isUserInteractionEnabled = true
                }
            default:
                return
            }

        default:
            return
        }
    }

    func handleDetailsSelection(at indexPath: IndexPath) {
        let attachments = viewModel.flatAttachments(for: indexPath.section)
        guard indexPath.row < attachments.count else { return }
        let attachment = attachments[indexPath.row]

        if let assignment = attachment as? Assessment, assignment.mappedType == .assignment {
            activeSubscreen = .exercise
            viewModel.selectedAssessmentSection = indexPath.section
            viewModel.assignmentsViewModel.assessments = viewModel.attachmentsOfLessons[indexPath.section]?.assignments ?? []
            switch assignment.mappedStatus {
            case .open:
                tableView.isUserInteractionEnabled = false
                viewModel.startAssessment(for: .assignment, at: indexPath) { [weak self] in self?.tableView.isUserInteractionEnabled = true }
            case .closed:
                tableView.isUserInteractionEnabled = false
                viewModel.showResultForAssessment(
                    type: assignment.mappedType,
                    at: indexPath
                ) { [weak self] in self?.tableView.isUserInteractionEnabled = true }
            }
        } else if let quiz = attachment as? Assessment, quiz.mappedType == .quiz {
            activeSubscreen = .quiz
            viewModel.selectedAssessmentSection = indexPath.section
            viewModel.quizzesViewModel.assessments = viewModel.attachmentsOfLessons[indexPath.section]?.quizzes ?? []
            viewModel.selectedAssessment = quiz
            switch quiz.mappedStatus {
            case .open:
                viewModel.startAssessment(for: .quiz, at: indexPath) { }
            case .closed:
                tableView.isUserInteractionEnabled = false
                viewModel.showResultForAssessment(
                    type: quiz.mappedType,
                    at: indexPath
                ) { [weak self] in self?.tableView.isUserInteractionEnabled = true }
            }
        } else if let video = attachment as? Video {
            handleVideoSelection(video)
        } else if let document = attachment as? Attachment {
            handleDocumentSelection(document)
        }
    }
}

// MARK: - Media & Document Handling

extension CourseDetailsViewController {
    func handleVideoSelection(_ video: Video) {
        guard !video.locked else {
            alertHandler.showInformationAlert(title: L10n.Global.Titles.warning, message: video.lockMessage ?? "")
            return
        }
        if video.isBunnyVideo {
            guard
                let guid = video.bunnyGuid,
                let libraryIdString = video.bunnyLibraryId,
                let libraryId = Int(libraryIdString),
                let apiKey = video.bunnyApiKey
            else {
                alertHandler.showInformationAlert(title: L10n.Global.Titles.warning, message: L10n.CourseDetails.Main.videoUnavailable)
                return
            }
            coordinator.showBunnyPlayer(
                guid: guid,
                libraryId: libraryId,
                apiKey: apiKey,
                fetchVideoDetails: { [weak self] completion in
                    Task {
                        _ = await self?.viewModel.fetchVideoDetails(videoId: "\(video.id)")
                        completion()
                    }
                },
                from: self
            )
        } else if let linkString = video.link, let url = URL(string: linkString), !(video.link?.isEmpty ?? true) {
            if video.link.isYouTubeLink {
                coordinator.showYouTubePlayer(url: url, from: self)
            } else {
                UIApplication.shared.open(url)
            }
        } else if !(video.vdocipherId?.isEmpty ?? true) {
            let presentVideoAction: () -> Void = { [weak self] in
                guard let self else { return }
                self.videoPlaybackService.presentVdoCipherVideo(
                    video,
                    transitioningDelegate: self,
                    from: self,
                    fetchAction: { completion in
                        Task {
                            let response = await self.viewModel.fetchVideoDetails(videoId: "\(video.id)")
                            completion(response)
                        }
                    }
                )
            }
            if viewModel.hideViews {
                presentVideoAction()
            } else {
                alertHandler.showConfirmAlert(
                    title: L10n.Global.Titles.warning,
                    message: L10n.CourseDetails.CourseReview.playVideo(video.viewsRemaining ?? 0),
                    confirmButtonTitle: L10n.Global.Actions.confirm
                ) { _ in
                    presentVideoAction()
                }
            }
        }
    }

    func handleDocumentSelection(_ document: Attachment) {
        activeSubscreen = .file
        if let linkString = document.link, let url = URL(string: linkString) {
            coordinator.showSafari(url: url, from: self)
        } else {
            let documentURL = AppEnvironment.baseURL.appendingPathComponent(document.fileUrl ?? "")
            let isPdf = document.mappedContentType == .pdf && AppEnvironment.appName == .squareCenter
            let documentTitle = document.title ?? document.fileName ?? ""
            coordinator.showDocumentViewer(title: documentTitle, urlString: documentURL.absoluteString, isPdf: isPdf, from: self)
        }
    }
}
