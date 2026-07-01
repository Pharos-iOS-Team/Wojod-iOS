// Copyright © 2026 Pharos Solutions. All rights reserved.

import BunnyStreamPlayer
import SwiftUI

struct BunnyPlayerView: View {
    @Environment(\.dismiss)
    var dismiss: DismissAction

    let videoId: String
    let libraryId: Int
    let apiKey: String
    private let phoneNumber: String = User.shared.mobileNumber ?? ""
    private let headers = ["Referer": "https://wojod.app/"]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                BunnyStreamPlayer(
                    accessKey: apiKey,
                    videoId: videoId,
                    libraryId: libraryId,
                    headers: headers
                )
                .tint(.white)
                .watermark(phoneNumber)
                Button {
                    dismiss()
                } label: {
                    VStack {
                        Image(systemSymbol: .xmark)
                            .foregroundColor(Color.white)
                            .font(.title)
                    }
                    .padding(7)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .contentShape(Circle())
                }
                .padding(.leading, geometry.size.height > geometry.size.width ? 30 : 45)
                .padding(.top, geometry.size.height > geometry.size.width ? 65 : 45)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: [.horizontal, .top])
            .background(.black)
            .navigationBarHidden(true)
        }
    }
}
