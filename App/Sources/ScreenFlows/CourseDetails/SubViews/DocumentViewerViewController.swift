// Copyright © 2026 Pharos Solutions. All rights reserved.

import PDFKit
import QuickLook
import UIKit

final class DocumentViewerViewController: UIViewController {
    // MARK: - Properties

    private let urlString: String
    private let isPdf: Bool
    private lazy var documentService = DocumentService(presentingViewController: self)
    private var previewURL: URL?
    private var hasStartedDownload: Bool = false

    // MARK: - UI Components

    private let progressContainer = UIView()
    private let trackLayer = CAShapeLayer()
    private let ringLayer = CAShapeLayer()
    private let percentLabel = UILabel()
    private let loadingLabel = UILabel()

    // MARK: - Init

    init(title: String, urlString: String, isPdf: Bool) {
        self.urlString = urlString
        self.isPdf = isPdf
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCloseButton()
        setupProgressRing()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStartedDownload else { return }
        hasStartedDownload = true
        startDownload()
    }

    // MARK: - Navigation Setup

    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    @objc
    private func closeTapped() {
        documentService.cancelDownload()
        progressContainer.removeFromSuperview()
        dismiss(animated: true)
    }

    // MARK: - Progress Ring

    private func setupProgressRing() {
        let size: CGFloat = 80
        let lineWidth: CGFloat = 6
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = (size - lineWidth) / 2

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        ).cgPath

        trackLayer.path = path
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = lineWidth

        ringLayer.path = path
        ringLayer.strokeColor = Colors.sendButtonColor.color.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = lineWidth
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 0

        let ringHostView = UIView()
        ringHostView.translatesAutoresizingMaskIntoConstraints = false
        ringHostView.layer.addSublayer(trackLayer)
        ringHostView.layer.addSublayer(ringLayer)

        percentLabel.text = "0%"
        percentLabel.font = .boldSystemFont(ofSize: 14)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        loadingLabel.text = "\(L10n.Global.Alerts.loading) .."
        loadingLabel.font = .systemFont(ofSize: 13)
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(ringHostView)
        progressContainer.addSubview(percentLabel)
        progressContainer.addSubview(loadingLabel)
        view.addSubview(progressContainer)

        NSLayoutConstraint.activate([
            progressContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            ringHostView.widthAnchor.constraint(equalToConstant: size),
            ringHostView.heightAnchor.constraint(equalToConstant: size),
            ringHostView.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            ringHostView.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),

            percentLabel.centerXAnchor.constraint(equalTo: ringHostView.centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: ringHostView.centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: ringHostView.bottomAnchor, constant: 10),
            loadingLabel.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor)
        ])
    }

    private func hideProgressRing() {
        progressContainer.removeFromSuperview()
    }

    // MARK: - Download

    private func startDownload() {
        if let cached = documentService.cachedFileURL(for: urlString) {
            displayDocument(at: cached)
            return
        }

        documentService.downloadToCache(
            urlString: urlString,
            progressHandler: { [weak self] progress in
                self?.updateProgress(progress)
            },
            completion: { [weak self] localURL in
                self?.displayDocument(at: localURL)
            },
            errorHandler: { [weak self] _ in
                self?.showDownloadError()
            }
        )
    }

    private func updateProgress(_ progress: Float) {
        ringLayer.strokeEnd = CGFloat(progress)
        percentLabel.text = "\(Int(progress * 100))%"
    }

    // MARK: - Document Display

    private func displayDocument(at url: URL) {
        isPdf ? showPDFView(at: url) : showDocumentPreview(url: url)
    }

    private func showPDFView(at url: URL) {
        hideProgressRing()

        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            pdfView.autoScales = true
        }
    }

    private func showDocumentPreview(url: URL) {
        hideProgressRing()
        previewURL = url

        let previewViewCtrl = QLPreviewController()
        previewViewCtrl.dataSource = self

        addChild(previewViewCtrl)
        previewViewCtrl.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewViewCtrl.view)

        NSLayoutConstraint.activate([
            previewViewCtrl.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewViewCtrl.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewViewCtrl.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewViewCtrl.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        previewViewCtrl.didMove(toParent: self)
    }

    // MARK: - Error Handling
    private func showDownloadError() {
        hideProgressRing()
        let alert = UIAlertController(
            title: L10n.Global.Titles.error,
            message: L10n.Global.Alerts.somethingWentWrong,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Global.Actions.ok, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource

extension DocumentViewerViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return previewURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let url = previewURL else { return NSURL(fileURLWithPath: "") }
        return url as QLPreviewItem
    }
}
