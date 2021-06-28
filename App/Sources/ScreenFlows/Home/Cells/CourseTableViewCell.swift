// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class CourseTableViewCell: UITableViewCell {
    // MARK: - IBOutlets

    @IBOutlet private var teacherNameLabel: UILabel!
    @IBOutlet private var coursesCollectionView: UICollectionView!

    // MARK: - Private Properties

    private var courses: [Course]?
    private var isMyCourses = Bool()

    // MARK: - Public Properties

    internal weak var delegate: ViewCourseDetailsDelegate?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    // MARK: - Private Functions

    private func configureCollectionView() {
        coursesCollectionView.register(UINib(nibName: "CourseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseCollectionViewCell")
        coursesCollectionView.dataSource = self
    }

    // MARK: - Public Functions

    func setTeacherName(_ name: String) {
        teacherNameLabel.text = name
    }

    func configureCourses(_ courses: [Course]?, isMyCourses: Bool) {
        self.courses = courses
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
        cell.delegate = delegate
        cell.playVideo = { () -> Void in
            cell.configureVideo(with: course?.video?.fileUrl ?? "")
        }
        return cell
    }
}
