// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVKit
import UIKit

class CustomAvPlayerController: AVPlayerViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.layer.sublayers?.last?.removeFromSuperlayer()
    }
}
