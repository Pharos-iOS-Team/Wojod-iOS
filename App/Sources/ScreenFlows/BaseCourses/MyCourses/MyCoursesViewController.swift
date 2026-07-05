// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftyUserDefaults
import UIKit

final class MyCoursesViewController: BaseCoursesViewController<MyCoursesViewModel>, UITableViewDataSource {
    @IBOutlet private var notificationButton: UIButton! {
        didSet {
            notificationButton.isHidden = Defaults[\.isGuestModeEnabled]
        }
    }
    @IBOutlet private var helpCenterButton: UIButton! {
        didSet {
            helpCenterButton.layer.cornerRadius = UIConstants.slightCornerRadius
        }
    }
    @IBOutlet private var helpCenterLabel: UILabel! {
        didSet {
            helpCenterLabel.text = L10n.Home.helpCenter
        }
    }
    @IBOutlet private var clearFiltersButton: UIButton?
    @IBOutlet private var filtersButton: UIButton?
    @IBOutlet private var filtersButtonHeightConstraint: NSLayoutConstraint?

    private var blurredView: UIVisualEffectView?
    private var isFirstScreenLoad: Bool = true

    convenience init(viewModel: MyCoursesViewModel) {
        self.init(nibName: "BaseCoursesViewController", bundle: nil)
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideFilterButtons()
    }

    override func configureTableView() {
        super.configureTableView()
        tableView.dataSource = self
        tableView.registerHeaderFooterView(ofType: HomeTableViewHeader.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.page = 1
        loadUserProfile { [weak self] in
            self?.loadCourses()
        }
    }

    override func tableViewHeader() -> UIView? {
        let headerView = tableView.dequeueHeaderFooterView(ofType: HomeTableViewHeader.self)
        headerView?.delegate = self
        headerView?.setSubjects(viewModel.subjects)
        headerView?.selectedSubjectIndexPath = viewModel.selectedSubjectIndexPath

        if isFirstScreenLoad {
            isFirstScreenLoad = false
            headerView?.selectRelatedCoursesButton()
        }

        headerView?.setButtonsVisibility(true)
        headerView?.setSubjectsVisibility(viewModel.mode == .relatedCourses)
        headerView?.setAdvertisementsVisibility(false)
        return headerView
    }

    @IBAction private func didTapNotificationsButton(_ sender: UIButton) {
        navigationCoordinator.showNotifications(from: self)
    }

    @IBAction private func didTapHelpCenterButton(_ sender: UIButton) {
        navigationCoordinator.showHelpCenter(from: self)
    }

    private func hideFilterButtons() {
        // Only hide filter-related buttons (not used in My Courses)
        clearFiltersButton?.isHidden = true
        filtersButton?.isHidden = true
    }

    private func showReceipt(_ receiptData: Receipt) {
        let receiptViewCtrl = ReceiptViewController(nibName: "ReceiptViewController", bundle: nil)
        receiptViewCtrl.myCourseReceipt = receiptData
        receiptViewCtrl.delegate = self
        receiptViewCtrl.modalPresentationStyle = .overFullScreen
        receiptViewCtrl.modalTransitionStyle = .crossDissolve
        self.present(receiptViewCtrl, animated: true)
    }

    private func blurView() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredView = blurEffectView
        self.view.addSubview(blurredView ?? blurEffectView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: CourseTableViewCell.self, for: indexPath)
        let subjectCourse = appropriateSubjectCourse(index: indexPath.row)

        cell?.configure(
            courses: subjectCourse?.courses,
            isMyCourses: true,
            teacherName: subjectCourse?.teacher?.name,
            teacherNameIndex: indexPath.row,
            courseDetailsDelegate: self,
            selectCellDelegate: self,
            viewReceiptDelegate: self
        )

        return cell ?? UITableViewCell()
    }
}

extension MyCoursesViewController: ViewReceiptDelegate, ReceiptDoneButtonDelegate {
    func displayReceipt(_ receipt: Receipt) {
        self.blurView()
        self.showReceipt(receipt)
    }

    func didTapDone() {
        blurredView?.removeFromSuperview()
    }
}

extension MyCoursesViewController: HomeTableViewHeaderDelegate {
    func didSelectSubject(at indexPath: IndexPath) {
        viewModel.selectedSubjectIndexPath = indexPath
        if indexPath.row < viewModel.subjects.count {
            let subject = viewModel.subjects[indexPath.row]
            viewModel.selectedSubject = subject
            viewModel.page = 1
            loadCourses()
        }
    }

    func didSelectRelatedCourses() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .relatedCourses)
        forceReloadCourses()
        tableView.reloadData()
    }

    func didSelectExploreMore() {
        viewModel.selectedSubjectIndexPath = .zero
        viewModel.changeMode(to: .exploreMore)
        forceReloadCourses()
        tableView.reloadData()
    }

    func textDidChange(in searchBar: UISearchBar) {
        viewModel.updateSearchText(searchBar.text ?? "")
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchMyCourses(_:)), with: searchBar, afterDelay: 0.75)
    }

    @objc
    private func searchMyCourses(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        loadCourses()
    }
}
