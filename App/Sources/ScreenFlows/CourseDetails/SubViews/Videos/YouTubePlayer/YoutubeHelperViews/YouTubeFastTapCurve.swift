// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct YouTubeFastTapCurve: Shape {
    private var isForward: Bool
    private var curveRadius: CGFloat

    public init(isForward: Bool, curveRadius: CGFloat = 40) {
        self.isForward = isForward
        self.curveRadius = curveRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        if isForward {
            // Curve on the left side
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))  // Top-right
            path.addLine(to: CGPoint(x: rect.minX + curveRadius, y: rect.minY)) // Top-left (offset to allow curve)
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + curveRadius, y: rect.maxY),
                control: CGPoint(x: rect.minX, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom-right
            path.closeSubpath()
        } else {
            // Curve on the right side
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))  // Top-left
            path.addLine(to: CGPoint(x: rect.maxX - curveRadius, y: rect.minY)) // Top-right (offset to allow curve)
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - curveRadius, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.midY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left
            path.closeSubpath()
        }
        return path
    }
}
