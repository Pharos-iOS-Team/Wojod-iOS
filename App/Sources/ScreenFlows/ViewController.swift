// Copyright © 2021 Pharos Solutions. All rights reserved.

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            let viewCtrl = StoryboardScene.Registration.initialScene.instantiate()
            self.present(viewCtrl, animated: true, completion: nil)
        }
    }
}
