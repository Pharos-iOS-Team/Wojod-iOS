// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation

extension AVAudioSession {
    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }
    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
}

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones
    }
}
