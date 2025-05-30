//
//  RenewIntentFailureView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.03.24.
//

import Foundation
import SwiftUI

struct RenewIntentFailureView: View {

    @ScaledMetric(wrappedValue: 40, relativeTo: .title) private var imageSize
    @ScaledMetric(wrappedValue: 0.75, relativeTo: .title) private var offsetFactor

    let renewAttemptedCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "checklist.unchecked")
                .foregroundColor(Color.red)
                .font(.system(size: imageSize))
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { d in d.height * offsetFactor }

            VStack {
                Text("none of the \(renewAttemptedCount) selected items have been renewed", bundle: .module)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("renewal intent not renewed error view hint", bundle: .module)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview("Failure") {
    RenewIntentFailureView(renewAttemptedCount: 1)
        .environment(\.locale, .init(identifier: "de"))
}
