// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct LoadingView: View {
    @Binding var loadingPercentage: String?

    public init(loadingPercentage: Binding<String?> = .constant(nil) ) {
        _loadingPercentage = loadingPercentage
    }

    public var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: Color(Colors.sendButtonColor.color))
                )
                .scaleEffect(1.5)

            if let percentage = loadingPercentage {
                Text("\(percentage)%")
                    .foregroundColor(Color.gray)
                    .font(.headline.bold())
                    .padding(.top)
            }
        }
        .frame(width: 100, height: 100, alignment: .center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
                .shadow(color: Color.gray, radius: 15)
        )
    }
}
