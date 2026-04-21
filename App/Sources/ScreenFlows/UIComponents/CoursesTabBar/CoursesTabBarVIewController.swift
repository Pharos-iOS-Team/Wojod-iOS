// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

enum TabBarItems: Int {
    case home
    case courses
    case settings
}

class CoursesTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarTintColor()
        setupTabBar()
    }

    // MARK: - tab bar setup methods
    private func setTabBarTintColor() {
        tabBar.tintColor = Colors.sendButtonColor.color
        tabBar.barTintColor = Colors.tabBarColor.color
    }

    private func setupTabBar() {
        setupTabBarForUser()
    }

    private func setupTabBarForUser() {
        let homeViewCtrl = HomeViewController(viewModel: .init())
        homeViewCtrl.tabBarItem = UITabBarItem(
            title: L10n.TabBar.home,
            image: Images.home.image.withRenderingMode(.alwaysOriginal),
            selectedImage: Images.homeSelected.image.withRenderingMode(.alwaysOriginal)
        )
        homeViewCtrl.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        let coursesViewCtrl = MyCoursesViewController(viewModel: .init())
        coursesViewCtrl.tabBarItem = UITabBarItem(
            title: L10n.TabBar.myCourses,
            image: Images.courses.image.withRenderingMode(.alwaysOriginal),
            selectedImage: Images.coursesSelected.image.withRenderingMode(.alwaysOriginal)
        )
        coursesViewCtrl.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        let settingsViewCtrl = setUpTabBarItem(
            title: L10n.TabBar.settings,
            itemImage: Images.settings.image,
            selectedItemImage: Images.settingsSelected.image,
            storyBoard: StoryboardScene.Settings.storyboard,
            viewCtrlIdentifier: StoryboardScene.Settings.settingsViewController.identifier
        )
        viewControllers = [homeViewCtrl, coursesViewCtrl, settingsViewCtrl]
    }

    private func setUpTabBarItem(
        title: String,
        itemImage: UIImage,
        selectedItemImage: UIImage,
        storyBoard: UIStoryboard,
        viewCtrlIdentifier: String
    ) -> UIViewController {
        let itemViewCtrl = storyBoard.instantiateViewController(withIdentifier: viewCtrlIdentifier).with {
            $0.tabBarItem = UITabBarItem(
                title: title,
                image: itemImage.withRenderingMode(.alwaysOriginal),
                selectedImage: selectedItemImage.withRenderingMode(.alwaysOriginal)
            )
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        return itemViewCtrl
    }
}
