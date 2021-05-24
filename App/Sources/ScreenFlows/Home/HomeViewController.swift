// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchUserProfile(id: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserProfile(id: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            let viewCtrl = StoryboardScene.Notifications.initialScene.instantiate()
            self.present(viewCtrl, animated: true)
        }
    }
}
