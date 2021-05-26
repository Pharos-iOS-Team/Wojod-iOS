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

    // TODO: delete this part
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewCtrl = StoryboardScene.CourseDetails.initialScene.instantiate()
        self.present(viewCtrl, animated: true)
    }
}
