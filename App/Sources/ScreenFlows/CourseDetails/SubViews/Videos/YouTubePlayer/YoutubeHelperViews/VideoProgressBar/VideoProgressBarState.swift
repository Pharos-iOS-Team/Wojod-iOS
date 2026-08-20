// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SwiftUI

public struct VideoProgressBarState {
    @Binding var playedTime: TimeInterval
    @Binding var bufferedTime: TimeInterval
    var videoDuration: Double

    public init(
        playedTime: Binding<TimeInterval>,
        bufferedTime: Binding<TimeInterval>,
        videoDuration: Double
    ) {
        self._playedTime = playedTime
        self._bufferedTime = bufferedTime
        self.videoDuration = videoDuration
    }
}
