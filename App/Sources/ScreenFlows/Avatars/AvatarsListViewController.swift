// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol AvatarsListDelegate: AnyObject {
    func setAvatar(avatar: Avatar)
}

class AvatarsListViewController: UIViewController {
    @IBOutlet private var avatarsCollectionView: UICollectionView! {
        didSet {
            avatarsCollectionView.dataSource = self
            avatarsCollectionView.delegate = self
        }
    }

    var avatars = [Avatar]()
    weak var delegate: AvatarsListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func getImage(from avatar: Avatar) -> UIImage {
        guard let link = avatar.thumbnailUrl else { return UIImage() }
        let url = Environment.baseURL.appendingPathComponent(link)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return UIImage() }
        return image
    }
}

extension AvatarsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AvatarCollectionViewCell = (
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "AvatarCollectionViewCell",
                for: indexPath
            ) as? AvatarCollectionViewCell ?? AvatarCollectionViewCell()
        )
        let image = getImage(from: avatars[indexPath.row])
        cell.configure(image: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presentingViewController?.dismiss(animated: true) {
            self.delegate?.setAvatar(avatar: self.avatars[indexPath.row])
        }
    }
}

extension AvatarsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5.0
    }
}
