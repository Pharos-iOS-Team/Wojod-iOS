// Copyright © 2026 Pharos Solutions. All rights reserved.

import Foundation
import SwiftUI

public struct MenuView<T: Displayable & Hashable>: View, Equatable {
    public static func == (lhs: MenuView<T>, rhs: MenuView<T>) -> Bool {
        return lhs.selectedOption == rhs.selectedOption && lhs.availableOptions == rhs.availableOptions
    }

    @Binding var selectedOption: T
    var availableOptions: [T]
    var startTimerAction: () -> Void
    var stopTimerAction: () -> Void
    var selectorImage: Image
    var selectorImageFrame: CGFloat

    public var body: some View {
        Menu {
            Picker("", selection: $selectedOption) {
                ForEach(availableOptions, id: \.self) { option in
                    Text(option.displayName)
                        .tag(option)
                        .onAppear {
                            if option == availableOptions[(availableOptions.count - 1) / 2] {
                                stopTimerAction()
                            }
                        }
                        .onDisappear {
                            if option == availableOptions[(availableOptions.count - 1) / 2] {
                                startTimerAction()
                            }
                        }
                }
            }
        } label: {
            VStack {
                selectorImage
                    .resizable()
                    .frame(width: selectorImageFrame, height: selectorImageFrame)
                    .accentColor(Color.gray.opacity(0.9))
            }
            .padding(.horizontal, 2)
            .background(Color.black.opacity(0.001))
            .contentShape(.rect)
        }
    }
}
