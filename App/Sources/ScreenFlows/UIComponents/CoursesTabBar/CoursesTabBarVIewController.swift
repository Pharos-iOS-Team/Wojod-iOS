// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

enum TabBarItems: Int {
    case home
    case courses
    case settings

    var indexOfTab: Int {
        return self.rawValue
    }
}

class CoursesTabBarViewController: UITabBarController {
    var user: LoginApiResponseModel?

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
        let homeViewCtrl = setUpTabBarItem(
            title: L10n.TabBar.home,
            itemImage: Images.home.image,
            selectedItemImage: Images.homeSelected.image,
            storyBoard: StoryboardScene.Home.storyboard,
            viewCtrlIdentifier: StoryboardScene.Home.homeViewController.identifier
        )
        let coursesViewCtrl = setUpTabBarItem(
            title: L10n.TabBar.myCourses,
            itemImage: Images.courses.image,
            selectedItemImage: Images.coursesSelected.image,
            storyBoard: StoryboardScene.Home.storyboard,
            viewCtrlIdentifier: StoryboardScene.Home.homeViewController.identifier
        )
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
