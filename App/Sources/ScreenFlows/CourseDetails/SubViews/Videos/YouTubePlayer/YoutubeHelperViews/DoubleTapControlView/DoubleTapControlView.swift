// Copyright © 2026 Pharos Solutions. All rights reserved.

import SwiftUI

public struct DoubleTapControlView: View {
    let state: DoubleTapControlState
    let singleTapAction: () -> Void
    let doubleTapAction: () -> Void

    private var isForward: Bool {
        return state.roundedCorners == [.topLeft, .bottomLeft]
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.0001)
                .frame(width: state.width / 3)
                .contentShape(Rectangle())

            Group {
                YouTubeFastTapCurve(isForward: isForward)
                    .frame(width: state.width / 3)
                    .foregroundColor(Color.gray.opacity(0.4))

                VStack {
                    Image(systemSymbol: isForward ? .forwardFill : .backwardFill)
                        .foregroundColor(Color.white)
                        .font(.body)

                    Text("10 \(L10n.Global.Titles.seconds)")
                        .foregroundColor(Color.white)
                        .font(.body.bold())
                        .lineLimit(1)
                }
                .padding(.leading, isForward ? 20 : -20)
                .scaleEffect(state.isActive ? 1 : 0.8)
            }
            .opacity(state.isActive ? 1 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: state.isActive)
        }
        .tapGesture(
            onSingleTap: { singleTapAction() },
            onDoubleTap: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    doubleTapAction()
                }
            }
        )
    }
}
