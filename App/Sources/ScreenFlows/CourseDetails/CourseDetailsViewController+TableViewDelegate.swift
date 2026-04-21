// Copyright © 2021 Pharos Solutions. All rights reserved.

import JGProgressHUD
import UIKit

// MARK: - UITableViewDelegate

extension CourseDetailsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        courseHeaderView?.applyStretchEffect(offset: scrollView.contentOffset.y)
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
        guard viewModel.activeScreen == .details, !viewModel.lessonsList.isEmpty else { return nil }
        let lesson = viewModel.lessonsList[section]
        let view = tableView.dequeueHeaderFooterView(ofType: CourseDetailsHeaderView.self)?.with {
            $0.tag = section
            $0.collapseExpandDelegate = self
            $0.setLessonTitleLabel(lesson.name)
            $0.setNumberLabel(viewModel.lessonNumbersList?[section] ?? 0)
            $0.assignSectionTagToButton(section)
            $0.configureVisibilityOfExpandButton(
                state: viewModel.course?.getReservationState(),
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
        viewModel.activeScreen == .details ? 60 : 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        viewModel.activeScreen == .details ? 60 : 0.0
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
            showLoadingIndicator()
            viewModel.fetchVideoDetails(videoId: "\(video.id)") { [weak self] _ in
                guard let self else { return }
                self.hideLoadingIndicator()
                self.coordinator.showBunnyPlayer(guid: guid, libraryId: libraryId, apiKey: apiKey, from: self)
            }
        } else if let linkString = video.link, let url = URL(string: linkString), !(video.link?.isEmpty ?? true) {
            if video.link.isYouTubeLink {
                coordinator.showYouTubePlayer(url: url, from: self)
            } else {
                UIApplication.shared.open(url)
            }
        } else if !(video.vdocipherId?.isEmpty ?? true) {
            if viewModel.hideViews {
                showLoadingIndicator()
                viewModel.fetchVideoDetails(videoId: "\(video.id)") { [weak self] response in
                    guard let self else { return }
                    self.videoPlaybackService.presentVdoCipherVideo(video, encryptedVideoResponse: response, transitioningDelegate: self, from: self)
                }
            } else {
                alertHandler.showConfirmAlert(
                    title: L10n.Global.Titles.warning,
                    message: L10n.CourseDetails.CourseReview.playVideo(video.viewsRemaining ?? 0),
                    confirmButtonTitle: L10n.Global.Actions.confirm
                ) { [weak self] _ in
                    guard let self else { return }
                    self.showLoadingIndicator()
                    self.viewModel.fetchVideoDetails(videoId: "\(video.id)") { [weak self] response in
                        guard let self else { return }
                        self.videoPlaybackService.presentVdoCipherVideo(video, encryptedVideoResponse: response, transitioningDelegate: self, from: self)
                    }
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
            if document.mappedContentType == .pdf && AppEnvironment.appName == .squareCenter {
                documentService.presentPDF(
                    from: documentURL.absoluteString,
                    progressHandler: { [weak self] progress in self?.updateDownloadHUD(progress: progress) },
                    onOpen: { [weak self] in self?.dismissDownloadHUD() }
                )
            } else {
                documentService.storeAndShare(
                    urlString: documentURL.absoluteString,
                    progressHandler: { [weak self] progress in self?.updateDownloadHUD(progress: progress) },
                    onOpen: { [weak self] in self?.dismissDownloadHUD() }
                )
            }
        }
    }

    func updateDownloadHUD(progress: Float) {
        if downloadHud == nil {
            let hud = JGProgressHUD(style: .light).with {
                $0.interactionType = .blockAllTouches
                $0.hudView.backgroundColor = .white
                $0.hudView.layer.shadowColor = UIColor.black.cgColor
                $0.hudView.layer.shadowOpacity = 0.18
                $0.hudView.layer.shadowOffset = CGSize(width: 0, height: 4)
                $0.hudView.layer.shadowRadius = 12
                $0.hudView.clipsToBounds = false
                let ring = JGProgressHUDRingIndicatorView()
                ring.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
                $0.indicatorView = ring
                $0.textLabel.text = "\(L10n.Global.Alerts.loading) \n 0%"
                $0.show(in: view, animated: true)
            }
            let xmarkConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
            let cancelButton = UIButton(type: .system).with {
                $0.setImage(UIImage(systemName: "xmark", withConfiguration: xmarkConfig), for: .normal)
                $0.tintColor = .systemGray2
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.addAction(UIAction { [weak self] _ in
                    self?.documentService.cancelDownload()
                    self?.dismissDownloadHUD()
                }, for: .touchUpInside)
            }
            hud.hudView.addSubview(cancelButton)
            NSLayoutConstraint.activate([
                cancelButton.topAnchor.constraint(equalTo: hud.hudView.topAnchor, constant: 8),
                cancelButton.trailingAnchor.constraint(equalTo: hud.hudView.trailingAnchor, constant: -8),
                cancelButton.widthAnchor.constraint(equalToConstant: 20),
                cancelButton.heightAnchor.constraint(equalToConstant: 20)
            ])
            downloadHud = hud
        }
        downloadHud?.setProgress(progress, animated: true)
        downloadHud?.textLabel.text = "\(L10n.Global.Alerts.loading) \n (\(Int(progress * 100))%)"
    }

    func dismissDownloadHUD() {
        downloadHud?.dismiss()
        downloadHud = nil
    }
}
