//
//  PlaceholderView.swift
//
//
//  Created by Martin Kim Dung-Pham on 25.11.22.
//

import Foundation
import SwiftUI

public struct PlaceholderView: View {

    private let hint: LocalizedStringKey
    private let tableName: String?
    private let bundle: Bundle?

    private let imageName: String?
    
    /// A component used for empy states with a large system image and some hint below
    /// - Parameters:
    ///   - imageName: a system image name like `smallcircle.filled.circle`
    ///   - hint: a hint that is displayed below the image
    ///   - tableName: if none is passed the default Localizable will be searched for the localized string key
    ///   - bundle: pass in the bundle where the localized string is located
    public init(imageName: String? = nil, hint: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil) {
        self.hint = hint
        self.imageName = imageName
        self.bundle = bundle
        self.tableName = tableName
    }

    public var body: some View {
        VStack {
            contentIf(imageName != nil) {
                Image(systemName: imageName!)
                    .font(.system(size: 60))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.secondary)
                    .padding(.top, 60)
                    .padding(.bottom)
            }

            Text(hint, tableName: tableName, bundle: bundle)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.title3)
        }
    }
}

import Localization

#Preview {
    PlaceholderView(imageName: "books.vertical", hint: "hint", tableName: nil, bundle: nil)
}
