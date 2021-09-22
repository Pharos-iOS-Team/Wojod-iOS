// Copyright © 2020 Pharos Solutions GmbH. All rights reserved.

// swiftlint:disable all

import HandySwift
import UIKit
import MobileCoreServices
import DTPhotoViewerController

class AssessmentQuestionViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet private var questionHeaderLabel: UILabel!
    @IBOutlet private var questionMarkLabel: UILabel!
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    // MARK: - Private properties

    private let textOptionCellHeight: CGFloat = 90
    private let imageOptionCellHeight: CGFloat = 120
    private let freeTextCellHeightRatio: CGFloat = 0.5
    private var viewModel: AssessmentQuestionViewModel?
    private var documentPicker: UIDocumentPickerViewController?
    private var documentInteractionController = UIDocumentInteractionController()
    private lazy var imagePicker = UIImagePickerController()
    private var selectedRowIndex: IndexPath?

    // MARK: - Public properties

    weak var delegate: AssessmentQuestionsDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        bindViewModel()
        registerNib()
        configureImagePicker()
    }
    
    // MARK: - Private functions

    private func initViewModel() {
        viewModel = AssessmentQuestionViewModel()
    }

    private func bindViewModel() {
        viewModel?.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func configureImagePicker() {
        imagePicker.delegate = self
    }

    private func configureHeaderLabel() {
        questionHeaderLabel.text = viewModel?.questionHeaderText
    }

    private func configureMarkLabel() {
        questionMarkLabel.text = viewModel?.questionMarkText
    }

    private func registerNib() {
        tableView.registerCell(ofType: QuestionHeaderTableViewCell.self)
        tableView.registerCell(ofType: AssessmentMCQOptionTableViewCell.self)
        tableView.registerCell(ofType: AssessmentFreeTextTableViewCell.self)
        tableView.registerCell(ofType: TeacherQuestionCommentTableViewCell.self)
    }

    private func setTableViewMultiSelection() {
        tableView.allowsMultipleSelection = viewModel?.isMultiSelection ?? false
    }

    private func showDocumentsPicker() {
        documentPicker = UIDocumentPickerViewController(
            documentTypes: [
                String(kUTTypeText),
                String(kUTTypeContent),
                String(kUTTypeItem),
                String(kUTTypeData),
                String(kUTTypePDF),
                String(kUTTypeImage)
            ],
            in: .open
        )
        documentPicker?.delegate = self
        documentPicker?.allowsMultipleSelection = false
        if let documentPicker = documentPicker,
            let parent = parent {
            parent.present(documentPicker, animated: true)
        }
    }

    private func scrollToTop() {
        guard tableView.numberOfSections > 0,
            tableView.numberOfRows(inSection: 0) > 0
            else { return }
        tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: false
        )
    }

    private func showActionSheet(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(title: L10n.Quizzes.camera, style: .default) { _ in
                self.openCamera()
            }
        )
        actionSheet.addAction(
            UIAlertAction(title: L10n.Quizzes.gallery, style: .default) { _ in
                self.openPhototLibrary()
            }
        )
        actionSheet.addAction(
            UIAlertAction(title: L10n.Quizzes.fileTitle, style: .default) { _ in
                self.showDocumentsPicker()
            }
        )
        actionSheet.addAction(
            UIAlertAction(title: L10n.Global.Actions.cancel, style: .cancel)
        )
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        parent?.present(actionSheet, animated: true)
    }

    private func openCamera() {
        imagePicker.sourceType = .camera
        parent?.present(imagePicker, animated: true)
    }

    private func openPhototLibrary() {
        imagePicker.sourceType = .photoLibrary
        parent?.present(imagePicker, animated: true)
    }

    private func saveImage(_ imageData: Data?) -> URL? {
        do {
            let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imageUniqueName: Int64 = Int64(NSDate().timeIntervalSince1970 * 1000)
            if let filePath = docDir?.appendingPathComponent("\(imageUniqueName).jpg") {
                do {
                    try imageData?.write(to: filePath)
                    return filePath
                } catch _ as NSError {
                    // AppAnalytics.couldNotUploadPhotoFromCamera(error: error)
                }
            }
        }
        return nil
    }

    private func saveFile(with url: URL) -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        do {
            let timeStamp = Date().timeIntervalSince1970.description
            let destinationURL = documentDirectory.appendingPathComponent(timeStamp + url.lastPathComponent)
            try FileManager.default.copyItem(
                at: url.standardizedFileURL,
                to: destinationURL
            )
            return destinationURL
        } catch {
            print(error)
            return nil
        }
    }

    // MARK: - Public functions

    func showQuestion(_ question: AssessmentQuestion) {
        viewModel?.setCurrentQuestion(question: question)
        configureHeaderLabel()
        configureMarkLabel()
        setTableViewMultiSelection()
        viewModel?.prepareDataSource()
        tableView.reloadData()
        scrollToTop()
    }

    func updateDownloadProgress(questionID: Int?, progress: Double) {
        guard let questionID = questionID,
            viewModel?.questionID == questionID else { return }
        setAttachmentProgressStatus(questionID, progress)
        let indexPaths = tableView.indexPathsForVisibleRows
        let freeTextQuestionIndexPath = indexPaths?.first { tableView.cellForRow(at: $0) is AssessmentFreeTextTableViewCell }
        
        guard let indexPath = freeTextQuestionIndexPath,
            let freeTextQuestionCell = tableView.cellForRow(at: indexPath) as? AssessmentFreeTextTableViewCell
            else { return }
        freeTextQuestionCell.setProgress(CGFloat(progress))
    }

    private func setAttachmentProgressStatus(_ questionID: Int?, _ progress: Double) {
        guard let questionID = questionID else { return }
        viewModel?.attachmentsProgressStatus[questionID] = progress
        if progress == 1.0 {
            viewModel?.isDownloadingAttachments[questionID] = false
        }
    }

    func setAssessmentStatus(_ status: AssessmentStatus?) {
        viewModel?.setAssessmentStatus(status)
    }

    func setCurrentModule(module: AssessmentsOverViewViewModel.Module) {
        viewModel?.module = module
    }
}

// MARK: - UITableViewDataSource
extension AssessmentQuestionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(for: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        let section = viewModel.dataSource[indexPath.section]
        switch section {
        case .header(let title, let image, let hasImage):
            let cell: QuestionHeaderTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.configure(questionTitle: title, hasImage: hasImage, questionImage: image, textAlignment: viewModel.textAlignment, delegate: self)
            return cell
        case .body(let items):
            let item = items[indexPath.row]
            return configureBodySection(for: item, at: indexPath)
        case let .note(note):
            let cell: TeacherQuestionCommentTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.configure(note: note ?? "")
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel?.getAssessmentStatus == .open else { return }
        let section = viewModel?.dataSource[indexPath.section]
        switch section {
        case .body(let items):
            switch items[indexPath.row] {
            case .selectableOption:
                viewModel?.didSelectOption(at: indexPath)
                delegate?.didAnswerQuestion(with: viewModel?.questionID)
                selectedRowIndex = indexPath
            default:
                return
            }
        default:
            return
        }
    }

    private func configureBodySection(for item: AssessmentQuestionViewModel.QuestionSectionItem, at indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        switch item {
        case .selectableOption(let title, let imageURL, let isSelected, let isCorrectAnswer, let isOpenAssessment):
            let cell: AssessmentMCQOptionTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.configure(optionName: title, optionImageURL: imageURL, isSelected: isSelected, textAlignment: viewModel.textAlignment, isCorrectAnswer: isCorrectAnswer, isOpenAssessment: isOpenAssessment, delegate: self)
            return cell
        case .textView(let answer, let alignment, let attachmentURLString, let isAnswered, let isCorrectAnswer, let answerState, let question, let isComment):
            let cell: AssessmentFreeTextTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.setDelegate(self)
            cell.setTextViewDelegate(self)
            cell.configure(with: answer, alignment: alignment, attachmentURLString: attachmentURLString, currentProgress: viewModel.currentProgress)
            cell.configureAnswer(isAnswered: isAnswered, isCorrectAnswer: isCorrectAnswer, module: viewModel.module, assignmentAnswerState: answerState, question: question, isComment: isComment)
            return cell
        default:
            return UITableViewCell()
        }
    }

    private func handleRemoveComment() {
        showAlert(
            imageName: "danger",
            title: nil,
            message: "homework.deleteCommentAlertMessage".localiz(),
            primaryButtonTitle: "homework.deleteTitle".localiz(),
            dismissButtonTitle: "app.cancel".localiz()
        ) { [weak self] in
            self?.dismiss(animated: true) {
                self?.delegate?.teacherAddOrEditComment(comment: "")
                self?.viewModel?.updateQuestionWith(comment: "")
                self?.tableView.reloadTableViewSections(withAnimation: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension AssessmentQuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = viewModel?.dataSource[indexPath.section]
        switch section {
        case .body(let items):
            let item = items[indexPath.row]
            switch item {
            case .textView:
                return freeTextCellHeightRatio * view.frame.height
            default:
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - UITableViewDelegate
extension AssessmentQuestionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel?.setFreeTextAnswer(textView.text)
        delegate?.didAnswerQuestion(with: viewModel?.questionID)
    }
}

// MARK: - AssessmentFreeTextDelegate
extension AssessmentQuestionViewController: AssessmentFreeTextDelegate {
    func didTapAttach(_ sender: UIButton) {
        showActionSheet(sender)
    }
    
    func didTapDeleteAttachment() {
        viewModel?.deleteQuestionAttachment()
        viewModel?.attachmentsProgressStatus.removeValue(forKey: viewModel?.questionID ?? -1)
        delegate?.didDeleteAttachedFile(for: viewModel?.questionID)
    }

    func didOpenAttachment() {
        guard
            let attachmentURL = viewModel?.getAttachmentURL(),
            let questionID = viewModel?.questionID,
            viewModel?.isDownloadingAttachments[questionID] != true
        else { return }

        viewModel?.isDownloadingAttachments[questionID] = attachmentURL.1
        delegate?.didOpenAttachment(
            with: attachmentURL.0,
            needsDownload: attachmentURL.1,
            questionID: viewModel?.questionID
        )
    }
}

// MARK: - UIDocumentPickerDelegate
extension AssessmentQuestionViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { _ = $0.startAccessingSecurityScopedResource() }
        guard let url = urls.first, let permenantURL = saveFile(with: url) else { return }
        viewModel?.setAttachedFileLocalURL(url: url)
        delegate?.didAttachFile(with: permenantURL, for: viewModel?.questionID)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AssessmentQuestionViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let imageData = image?.compress(maxSize: 2000000, minSize: 1000000, times: 10)
        guard let savedImageURL = saveImage(imageData) else { return }
        picker.dismiss(animated: true)
        viewModel?.setAttachedFileLocalURL(url: savedImageURL)
        delegate?.didAttachFile(with: savedImageURL, for: viewModel?.questionID)
    }
}

// MARK: - PreviewImageDelegate
extension AssessmentQuestionViewController: PreviewQuestionImageDelegate, UIDocumentInteractionControllerDelegate {
    func previewImage(imageView: UIImageView, image: UIImage) {
        preview(imageView: imageView, image: image)
    }
    
    private func preview(imageView: UIImageView, image: UIImage) {
        let viewController = DTPhotoViewerController(referencedView: imageView, image: image)
        present(viewController, animated: true)
    }
    
    @objc private func share(url: URL) {
        documentInteractionController.delegate = self
        documentInteractionController.url = url
        documentInteractionController.uti = String(kUTTypeJPEG)
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
