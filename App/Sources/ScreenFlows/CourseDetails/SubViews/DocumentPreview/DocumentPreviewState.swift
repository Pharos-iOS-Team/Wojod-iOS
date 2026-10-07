// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation

final class DocumentPreviewState: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var documentURL: URL?
    @Published var loadingPercentage: String?

    func setProgress(_ progress: Float) {
        loadingPercentage = progress > 0 ? "\(Int(progress * 100))" : nil
    }

    func setReady(url: URL) {
        documentURL = url
        isLoading = false
        loadingPercentage = nil
    }
}
