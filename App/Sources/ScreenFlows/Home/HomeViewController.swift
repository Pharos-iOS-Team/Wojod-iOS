// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class HomeViewController: UIViewController {
    let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getUserProfile(id: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserProfile(id: 0)
    }
}
