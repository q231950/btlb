//
//  ExpirationNotificationView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 12.04.23.
//

import Foundation
import SwiftUI

public struct ExpirationNotificationView: View {

    private var text: String?

    public init(_ text: String?) {
        self.text = text
    }

    public var body: some View {
        Group {
            if let text = text {
                HStack {
                    Image(systemName: "clock.badge")

                    Text(text)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary.opacity(0.15))
                .cornerRadius(12)
            } else {
                EmptyView()
            }
        }
        .padding([.leading, .trailing])
    }
}

struct ExpirationNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpirationNotificationView("Hello, world!")
    }
}
