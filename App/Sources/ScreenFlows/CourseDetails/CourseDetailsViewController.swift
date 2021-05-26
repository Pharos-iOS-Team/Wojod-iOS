// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

internal enum CourseState {
    case normal
    case pending
    case booked
}

class CourseDetailsViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var detailsButton: UIButton! {
        didSet {
            detailsButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var materialsButton: UIButton! {
        didSet {
            materialsButton.layer.cornerRadius = 5
            materialsButton.isHidden = !(self.state == .booked)
        }
    }
    @IBOutlet private var reviewsButton: UIButton! {
        didSet {
            reviewsButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = 10
            actionButton.setTitle("Book Now")
        }
    }

    // MARK: - Private Properties

    private var state: CourseState?
    private var viewModel: CourseDetailsViewModel?
    private var lessonsList: [Lesson]?
    private var lessonNumbersList: [Int]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = .normal
        viewModel = CourseDetailsViewModel()
        loadCourseLessons()
        configureTableView()
    }

    // MARK: - IBActions

    @IBAction private func didTapDetails(_ sender: UIButton) {
        select(button: detailsButton)
        unselect(button: materialsButton)
        unselect(button: reviewsButton)
    }

    @IBAction private func didTapMaterials(_ sender: UIButton) {
        select(button: materialsButton)
        unselect(button: detailsButton)
        unselect(button: reviewsButton)
    }

    @IBAction private func didTapReviews(_ sender: UIButton) {
        select(button: reviewsButton)
        unselect(button: detailsButton)
        unselect(button: materialsButton)
    }

    // MARK: - Private Functions

    private func configureTableView() {
        tableView.register(UINib(nibName: "AttachmentTableViewCell", bundle: nil), forCellReuseIdentifier: "AttachmentTableViewCell")
        let headerNib = UINib(nibName: "CourseDetailsHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CourseDetailsHeaderView")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func select(button: UIButton) {
        button.layer.backgroundColor = Colors.lightAccentColor.color.cgColor
        button.setTitleColor(Colors.sendButtonColor.color, for: .normal)
    }

    private func unselect(button: UIButton) {
        button.layer.backgroundColor = Colors.lightGreyColor.color.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
    }

    private func loadCourseLessons() {
        viewModel?.loadLessons(courseID: 32) { lessonsModel in
            self.lessonsList = lessonsModel.lessons
            self.generateLessonsNumbersList()
            self.tableView.reloadData()
        }
    }

    private func generateLessonsNumbersList() {
        let numberOfLessons = lessonsList?.count ?? 0
        lessonNumbersList = Array(1 ... numberOfLessons)
    }
}

// MARK: - Table View Data Source

extension CourseDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lessonsList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.state == .normal ? 0 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentTableViewCell", for: indexPath) as? AttachmentTableViewCell
        cell?.setAttachmentImageView(Images.pdf.image)
        return cell ?? UITableViewCell()
    }
}

// MARK: - Table View Delegate

extension CourseDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CourseDetailsHeaderView")  as? CourseDetailsHeaderView
        view?.collapseExpandDelegate = self
        let lesson = lessonsList?[section]
        view?.setLessonTitleLabel(lesson?.name ?? "Lesson")
        view?.setNumberLabel(lessonNumbersList?[section] ?? 0)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = Colors.lightGreyColor.color
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - Collapse Expand Delegate

extension CourseDetailsViewController: CollapseExpandDelegate {
    func didTapOnCollapseExpand() {
        print("TAPPED!")
    }
}
