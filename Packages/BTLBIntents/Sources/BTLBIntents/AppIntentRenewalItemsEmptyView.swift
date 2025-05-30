//
//  AppIntentRenewalItemsEmptyView.swift
//
//
//  Created by Martin Kim Dung-Pham on 11.03.24.
//

import Foundation
import SwiftUI

public struct AppIntentRenewalItemsEmptyView: View {

    @ScaledMetric(wrappedValue: 40, relativeTo: .title) private var imageSize
    @ScaledMetric(wrappedValue: 0.75, relativeTo: .title) private var offsetFactor

    public init() {}

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(Color.yellow)
                .font(.system(size: imageSize))
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { d in d.height * offsetFactor }

            VStack {
                Text("no items available for renewal", bundle: .module)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("renewal intent empty view hint", bundle: .module)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview {
    AppIntentRenewalItemsEmptyView()
}
