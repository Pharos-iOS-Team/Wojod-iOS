// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import UIScrollView_InfiniteScroll

protocol SelectCourseCellDelegate: AnyObject {
    func showCourseDetails(for course: Course?, with teacherNameIndex: Int)
}

class CourseTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var coursesCollectionView: UICollectionView!

    // MARK: - Private Properties

    private var courses: [Course]?
    private var isMyCourses = Bool()

    // MARK: - Public Properties

    internal weak var delegate: ViewCourseDetailsDelegate?
    internal weak var viewReceiptDelegate: ViewReceiptDelegate?
    internal weak var selectCellDelegate: SelectCourseCellDelegate?
    internal var teacherNameIndex: Int?
    internal var viewModel: HomeViewModel?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnyPlayingVideoIfAny()

        courses = nil
        teacherNameLabel.text = nil
    }

    // MARK: - Private Functions

    private func configureCollectionView() {
        coursesCollectionView.registerCell(ofType: CourseCollectionViewCell.self)
        coursesCollectionView.dataSource = self
        coursesCollectionView.delegate = self
    }

    // MARK: - Public Functions
    // swiftlint:disable:next function_parameter_count
    func configure(
        courses: [Course]?,
        isMyCourses: Bool,
        teacherName: String?,
        teacherNameIndex: Int,
        courseDetailsDelegate: ViewCourseDetailsDelegate?,
        selectCellDelegate: SelectCourseCellDelegate?,
        viewReceiptDelegate: ViewReceiptDelegate? = nil
    ) {
        let hasDataChanged = self.courses?.count != courses?.count || self.isMyCourses != isMyCourses
        guard hasDataChanged else { return }

        self.courses = courses
        self.isMyCourses = isMyCourses
        self.teacherNameLabel.text = teacherName
        self.teacherNameIndex = teacherNameIndex
        self.delegate = courseDetailsDelegate
        self.selectCellDelegate = selectCellDelegate
        self.viewReceiptDelegate = viewReceiptDelegate

        DispatchQueue.main.async { [weak self] in
            self?.coursesCollectionView.reloadData()
        }
    }

    func setTeacherName(_ name: String) {
        teacherNameLabel.text = name
    }

    func stopAnyPlayingVideoIfAny() {
        for cell in coursesCollectionView.visibleCells {
            if let courseCell = cell as? CourseCollectionViewCell {
                courseCell.stopVideoIfTheresAnyPlaying()
            }
        }
    }
}

// MARK: - Collection View Data Source

extension CourseTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CourseCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        let course = courses?[indexPath.item]
        cell.configure(with: course, isMyCourses: isMyCourses)
        cell.teacherNameIndex = teacherNameIndex
        cell.delegate = delegate
        cell.viewReceiptDelegate = viewReceiptDelegate
        cell.playVideo = {
            cell.configureVideo(with: course?.video?.fileUrl ?? "")
        }
        return cell
    }
}

// MARK: - Collection View Delegate

extension CourseTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CourseCollectionViewCell
        selectCellDelegate?.showCourseDetails(for: courses?[indexPath.item], with: cell?.teacherNameIndex ?? 0)
    }
}
