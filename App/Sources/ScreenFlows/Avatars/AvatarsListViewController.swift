// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

protocol AvatarsListDelegate: AnyObject {
    func setAvatar(avatar: Avatar?)
}

class AvatarsListViewController: UIViewController {
    @IBOutlet private var avatarsCollectionView: UICollectionView! {
        didSet {
            avatarsCollectionView.dataSource = self
            avatarsCollectionView.delegate = self
        }
    }
    @IBOutlet private var confirmButton: UIButton! {
        didSet {
            confirmButton.setTitle(L10n.Global.Actions.confirm)
        }
    }

    var avatars = [Avatar]()
    weak var delegate: AvatarsListDelegate?
    private var previouslySelectedAvatarIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func didTapConfirm(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true) {
            if self.previouslySelectedAvatarIndexPath == nil {
                self.delegate?.setAvatar(avatar: nil)
            } else {
                self.delegate?.setAvatar(
                    avatar: self.avatars[self.previouslySelectedAvatarIndexPath?.item ?? .zero]
                )
            }
        }
    }

    private func getImage(from avatar: Avatar) -> UIImage {
        guard let link = avatar.thumbnailUrl else { return UIImage() }
        let url = AppEnvironment.baseURL.appendingPathComponent(link)
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return UIImage() }
        return image
    }
}

extension AvatarsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AvatarCollectionViewCell = collectionView.dequeCell(indexPath: indexPath)
        let image = getImage(from: avatars[indexPath.row])
        cell.configure(image: image, isSelected: isAvatarSelected(indexPath: indexPath))
        if isAvatarSelected(indexPath: indexPath) {
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        if User.shared.avatar?.id == nil {
            for cell in collectionView.visibleCells {
                if let avatarCell = cell as? AvatarCollectionViewCell {
                    avatarCell.selectImage()
                }
            }
        }
        return cell
    }

    func isAvatarSelected(indexPath: IndexPath) -> Bool {
        if avatars[indexPath.row].id == User.shared.avatar?.id || User.shared.avatar?.id == nil {
            return true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == previouslySelectedAvatarIndexPath {
            previouslySelectedAvatarIndexPath = nil
            for cell in collectionView.visibleCells {
                if let avatarCell = cell as? AvatarCollectionViewCell {
                    avatarCell.selectImage()
                    avatarCell.isCellSelected = false
                }
            }
        } else {
            previouslySelectedAvatarIndexPath = indexPath
            for cell in collectionView.visibleCells {
                if let avatarCell = cell as? AvatarCollectionViewCell {
                    cell.isSelected ? avatarCell.selectImage() : avatarCell.unselectImage()
                }
            }
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
