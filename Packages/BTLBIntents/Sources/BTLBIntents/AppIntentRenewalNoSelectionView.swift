//
//  AppIntentRenewalNoSelectionView.swift
//
//
//  Created by Martin Kim Dung-Pham on 11.03.24.
//

import Foundation
import SwiftUI

public struct AppIntentRenewalNoSelectionView: View {

    @ScaledMetric(wrappedValue: 40, relativeTo: .title) private var imageSize
    @ScaledMetric(wrappedValue: 0.75, relativeTo: .title) private var offsetFactor

    public init() {}

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "0.circle.fill")
                .foregroundColor(Color.yellow)
                .font(.system(size: imageSize))
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { d in d.height * offsetFactor }

            VStack {
                Text("no items selected for renewal", bundle: .module)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("no items selected for renewal hint", bundle: .module)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview {
    AppIntentRenewalNoSelectionView()
}
