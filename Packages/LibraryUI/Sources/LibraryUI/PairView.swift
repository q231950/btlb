//
//  PairView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 30.03.22.
//

import Foundation
import SwiftUI
import Localization


public struct PairView: View {

    private let key: String
    private let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(key)
                    .font(.body)
                    .bold()
                    .frame(alignment: .leading)

                Spacer()
            }
            .padding(.bottom, 2)

            valueView(value)
            /// This catches any outgoing URLs.
                .handleOpenURLInApp()
        }
        .padding([.leading, .trailing, .bottom], 20)
    }

    @ViewBuilder private func valueView(_ value: String) -> some View {
        Group {
            if value.hasPrefix("http://") || value.hasPrefix("https://") {
                ForEach(value.components(separatedBy: .whitespacesAndNewlines)) { component in
                    if component.hasPrefix("http") {
                        Link(component, destination: URL(string: component)!)
                    } else {
                        textValue(component)
                    }
                }
            } else {
                textValue(value)
            }
        }
    }

    @ViewBuilder private func textValue(_ value: String) -> some View {
        Text(value)
            .textSelection(.enabled)
            .font(.body)
            .frame(alignment: .leading)
    }
}

extension String: @retroactive Identifiable {
    public var id: String {
        self
    }
}

#if DEBUG
struct PairView_Previews: PreviewProvider {

    static var previews: some View {
        PairView(key: "Key", value: "Value")
            .previewLayout(.sizeThatFits)

        PairView(key: "Key", value: "Value")
            .previewLayout(.sizeThatFits)
            .background(Color(UIColor.systemBackground))
            .environment(\.colorScheme, .dark)
    }
}
#endif
