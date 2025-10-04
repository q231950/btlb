//
//  RenewIntentPartialSuccessView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.03.24.
//

import Foundation
import SwiftUI

struct RenewIntentPartialSuccessView: View {

    @ScaledMetric(wrappedValue: 40, relativeTo: .title) private var imageSize
    @ScaledMetric(wrappedValue: 0.75, relativeTo: .title) private var offsetFactor

    let renewAttemptedCount: Int
    let renewedCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "checklist")
                .foregroundColor(Color.yellow)
                .font(.system(size: imageSize))
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { d in d.height * offsetFactor }

            VStack {
                Text("only \(renewedCount) of the \(renewAttemptedCount) selected items have been renewed", bundle: .module)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("renewal intent not renewed partial error view hint", bundle: .module)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview("Partial") {
    RenewIntentPartialSuccessView(renewAttemptedCount: 2, renewedCount: 1)
}
