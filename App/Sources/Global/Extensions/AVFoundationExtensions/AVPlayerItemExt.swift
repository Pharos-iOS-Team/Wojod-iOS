// Copyright © 2021 Pharos Solutions. All rights reserved.

import AVFoundation

extension AVPlayerItem {
    func totalBuffer() -> Double {
        return loadedTimeRanges.map { $0.timeRangeValue }.reduce(0) { acc, cur in
            return acc + CMTimeGetSeconds(cur.start) + CMTimeGetSeconds(cur.duration)
        }
    }

    func currentBuffer() -> Double {
        let currentTime = self.currentTime()
        guard
            let timeRange = loadedTimeRanges.map({ $0.timeRangeValue })
                .first(where: { $0.containsTime(currentTime) })
        else { return -1 }

        return CMTimeGetSeconds(timeRange.end) - currentTime.seconds
    }
}
