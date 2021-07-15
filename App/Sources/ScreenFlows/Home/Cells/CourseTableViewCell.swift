// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

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

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    // MARK: - Private Functions

    private func configureCollectionView() {
        coursesCollectionView.register(UINib(nibName: "CourseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseCollectionViewCell")
        coursesCollectionView.dataSource = self
        coursesCollectionView.delegate = self
    }

    // MARK: - Public Functions

    func setTeacherName(_ name: String) {
        teacherNameLabel.text = name
    }

    func configureCourses(_ courses: [Course]?, isMyCourses: Bool) {
        self.courses = courses
        self.isMyCourses = isMyCourses
        coursesCollectionView.reloadData()
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
        cell.playVideo = { () -> Void in
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
