// Copyright © 2026 Pharos Solutions GmbH. All rights reserved.

import Foundation

extension YTPlayerView {
  /// Clear cache to address the quality degradation issue reported by the customer.
  @objc func clearWebKitCache(completion: (() -> Void)? = nil) {
    let types: Set<String> = [
      WKWebsiteDataTypeDiskCache,
      WKWebsiteDataTypeMemoryCache,
      WKWebsiteDataTypeOfflineWebApplicationCache
    ]
    let date = Date(timeIntervalSince1970: 0)
    
    WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: date) {
      print("WebKit cache cleared successfully")
      
      URLCache.shared.removeAllCachedResponses()
      completion?()
    }
  }
}
