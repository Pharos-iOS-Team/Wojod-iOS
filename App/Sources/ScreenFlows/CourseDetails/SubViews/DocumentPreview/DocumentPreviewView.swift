// Copyright © 2026 Pharos Solutions. All rights reserved.

import Combine
import QuickLook
import SwiftUI
import UIKit

struct DocumentPreviewView: View {
    @ObservedObject var state: DocumentPreviewState
    let title: String
    let contentType: DocumentContentType
    let allowShare: Bool
    let watermarkText: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let url = state.documentURL {
                ZStack {
                    DocumentPreview(
                        url: url,
                        title: title,
                        contentType: contentType,
                        allowShare: allowShare,
                        onDismiss: onDismiss
                    )
                    .ignoresSafeArea()

                    if !watermarkText.isEmpty {
                        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
                        Text(watermarkText)
                            .font(.system(size: UIScreen.main.bounds.width / (isLandscape ? 24.0 : 8.0), weight: .bold))
                            .minimumScaleFactor(0.3)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .allowsTightening(true)
                            .rotationEffect(.degrees(45))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(maxWidth: isLandscape ? UIScreen.main.bounds.height : .infinity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .ignoresSafeArea()
            }

            // Loading overlay
            if state.isLoading {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                LoadingView(loadingPercentage: $state.loadingPercentage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Cancel button
            Button(action: onDismiss) {
                Image(systemSymbol: .xmark)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(Colors.darkGreyColor.color))
                    .frame(width: 30, height: 30)
            }
            .padding(.leading, 30)
            .padding(.top, 60)
            .isHidden(!state.isLoading)
        }
        .ignoresSafeArea()
    }
}
