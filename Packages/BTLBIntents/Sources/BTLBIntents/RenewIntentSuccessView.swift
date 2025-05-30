//
//  RenewIntentSuccessView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.03.24.
//

import Foundation
import SwiftUI

struct RenewIntentSuccessView: View {

    @ScaledMetric(wrappedValue: 40, relativeTo: .title) private var imageSize
    @ScaledMetric(wrappedValue: 0.75, relativeTo: .title) private var offsetFactor

    let renewedCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "checklist.checked")
                .foregroundColor(Color.green)
                .font(.system(size: imageSize))
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { d in d.height * offsetFactor }

            VStack {
                Text("all \(renewedCount) selected items have been renewed", bundle: .module)
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview("Success") {
    RenewIntentSuccessView(renewedCount: 2)
        .environment(\.locale, .init(identifier: "de"))
}

