// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit
import UIScrollView_InfiniteScroll

class CourseTableViewCell: UITableViewCell {
    struct CourseTableViewCellModel {
        let courses: [Course]?
        let isMyCourses: Bool
        let teacherName: String?
    }
    // MARK: - IBOutlets

    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var coursesCollectionView: UICollectionView!

    // MARK: - Private Properties

    private var courses: [Course]?
    private var isMyCourses = Bool()

    // MARK: - Public Properties

    internal var teacherNameIndex: Int?
    internal var viewModel: HomeViewModel?
    internal var onShowCourseDetails: ((Course?, Int) -> Void)?
    internal var onDisplayReceipt: ((Receipt) -> Void)?

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
        onShowCourseDetails = nil
        onDisplayReceipt = nil
    }

    // MARK: - Private Functions

    private func configureCollectionView() {
        coursesCollectionView.registerCell(ofType: CourseCollectionViewCell.self)
        coursesCollectionView.dataSource = self
        coursesCollectionView.delegate = self
    }

    // MARK: - Public Functions
    func configure(model: CourseTableViewCellModel, teacherNameIndex: Int) {
        let hasDataChanged = self.courses?.count != model.courses?.count || self.isMyCourses != model.isMyCourses
        guard hasDataChanged else { return }

        self.courses = model.courses
        self.isMyCourses = model.isMyCourses
        self.teacherNameLabel.text = model.teacherName
        self.teacherNameIndex = teacherNameIndex

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
        cell.onShowCourseDetails = onShowCourseDetails
        cell.onDisplayReceipt = onDisplayReceipt
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
        onShowCourseDetails?(courses?[indexPath.item], cell?.teacherNameIndex ?? 0)
    }
}
