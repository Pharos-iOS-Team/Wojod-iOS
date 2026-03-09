// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

// swiftlint:disable function_body_length
public struct WatermarkModifier: ViewModifier {
    let watermarkText: String
    @Binding var hideWatermark: Bool

    private let labelHeight: CGFloat = 20
    private let labelWidth: CGFloat = .deviceAdjusted(phone: 140, pad: 180)

    @State private var watermarkPosition = CGPoint(
        x: UIScreen.main.bounds.midX,
        y: UIScreen.main.bounds.midY
    )
    @State private var watermarkTimer = Timer.publish(
        every: GlobalConstants.watermarkPositionChangeInterval,
        on: .main,
        in: .common
    ).autoconnect()

    public init(
        watermarkText: String,
        hideWatermark: Binding<Bool>
    ) {
        self.watermarkText = watermarkText
        self._hideWatermark = hideWatermark
    }

    public func body(content: Content) -> some View {
        content
            .overlay(
                Text(watermarkText)
                    .frame(width: labelWidth, height: labelHeight, alignment: .center)
                    .font(.body.bold())
                    .foregroundColor(.gray)
                    .position(watermarkPosition)
                    .allowsHitTesting(false)
                    .isHidden(hideWatermark)
                    .onReceive(watermarkTimer) { _ in
                        moveWatermark()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            moveWatermark()
                        }
                    }
            )
    }

    private func moveWatermark() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let minX: CGFloat = 80
        let minY: CGFloat = .orientationAdjusted(
            portrait: (screenHeight * 0.4) + labelHeight,
            landscape: (screenHeight * 0.15)
        )

        let maxX: CGFloat = .orientationAdjusted(
            portrait: screenWidth - labelWidth + 30,
            landscape: screenWidth - labelWidth - 30
        )
        let maxY: CGFloat = .orientationAdjusted(
            portrait: (screenHeight * 0.65) - labelHeight,
            landscape: (screenHeight * 0.9) - labelHeight
        )

        guard minX < maxX, minY < maxY else {
            watermarkPosition = CGPoint(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY
            )
            return
        }
        watermarkPosition = CGPoint(
            x: CGFloat.random(in: minX ... maxX),
            y: CGFloat.random(in: minY ... maxY)
        )
    }
}

public extension View {
    func watermark(
        _ watermarkText: String,
        hideWatermark: Binding<Bool> = .constant(false)
    ) -> some View {
        self.modifier(WatermarkModifier(watermarkText: watermarkText, hideWatermark: hideWatermark))
    }
}
// swiftlint:enable function_body_length
