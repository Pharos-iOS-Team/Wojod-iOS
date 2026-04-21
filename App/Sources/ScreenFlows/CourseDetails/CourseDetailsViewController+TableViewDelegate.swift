// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

// MARK: - UITableViewDelegate

extension CourseDetailsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        courseHeaderView?.applyStretchEffect(offset: scrollView.contentOffset.y + scrollView.contentInset.top)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.activeScreen == .details ? detailsRowHeight : reviewsRowHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.activeScreen {
        case .details:
            return detailsRowHeight
        case .materials:
            return reviewsRowHeight
        case .reviews:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewModel.activeScreen == .details, !viewModel.lessonsList.isEmpty, !isContentLoading else { return nil }
        let lesson = viewModel.lessonsList[section]
        let view = tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)?.with {
            $0.tag = section
            $0.onCollapseExpand = { [weak self] section in
                guard let self else { return }
                let wasExpanded = self.viewModel.expandedSections.contains(section)
                let oldRowCount = self.viewModel.numberOfRowsForLesson(section: section)
                self.viewModel.toggleSectionExpansion(section) {
                    if wasExpanded {
                        let indexPaths = (0 ..< oldRowCount).map { IndexPath(row: $0, section: section) }
                        self.tableView.performBatchUpdates {
                            self.tableView.deleteRows(at: indexPaths, with: .fade)
                        }
                    } else {
                        let newRowCount = self.viewModel.numberOfRowsForLesson(section: section)
                        let indexPaths = (0 ..< newRowCount).map { IndexPath(row: $0, section: section) }
                        self.tableView.performBatchUpdates {
                            self.tableView.insertRows(at: indexPaths, with: .automatic)
                        }
                    }
                    if let header = self.tableView.headerView(forSection: section) as? CourseDetailsHeaderView {
                        header.animateExpandCollapse(isExpanded: !wasExpanded)
                    }
                }
            }
            $0.setLessonTitleLabel(lesson.name)
            $0.setNumberLabel(viewModel.lessonNumbersList?[section] ?? 0)
            $0.assignSectionTagToButton(section)
            $0.configureVisibilityOfExpandButton(
                state: viewModel.course?.parsedReservationState,
                doesContainAttachments: viewModel.doesLessonContainAttachments[section] ?? false
            )
        }
        if lesson.locked {
            view?.setImageOfButton(Images.lock.image)
        } else {
            view?.setImageOfButton(viewModel.expandedSections.contains(section) ? Images.collapse.image : Images.expand.image)
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.activeScreen == .details && !isContentLoading) ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        (viewModel.activeScreen == .details && !isContentLoading) ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.activeScreen == .details ? 5.0 : 0.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.activeScreen == .materials {
            handleMaterialsSelection(at: indexPath)
        } else if viewModel.activeScreen == .details {
            handleDetailsSelection(at: indexPath)
        }
    }
}

// MARK: - Row Selection

extension CourseDetailsViewController {
    private func handleMaterialsSelection(at indexPath: IndexPath) {
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

    private func handleDetailsSelection(at indexPath: IndexPath) {
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
