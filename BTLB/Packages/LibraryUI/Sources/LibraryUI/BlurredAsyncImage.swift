//
//  BlurredAsyncImage.swift
//  
//
//  Created by Martin Kim Dung-Pham on 30.03.22.
//

import Foundation
import SwiftUI

public struct BlurredAsyncImage<PlaceholderContent: View>: View {

    private let edgeLength: CGFloat
    private let imageUrl: URL?
    private let placeholder: ((CGFloat) -> PlaceholderContent)

    public init(edgeLength: CGFloat, url: URL?, placeholder: @escaping (CGFloat) -> PlaceholderContent) {
        self.edgeLength = edgeLength
        self.imageUrl = url
        self.placeholder = placeholder
    }

    public var body: some View {
        AsyncImage(url: imageUrl) { image in
            ZStack {
                image
                    .resizable()
                    .blur(radius: 20)
                    .frame(width: edgeLength, height: edgeLength, alignment: .center)
                    .opacity(0.6)

                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding([.top, .bottom], 30)
                    .padding([.leading, .trailing], 10)
                    .frame(width: edgeLength, height: edgeLength, alignment: .center)
            }
        } placeholder: {
            placeholder(edgeLength)
        }
    }
}

#if DEBUG
struct BlurredAsyncImagePreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        BlurredAsyncImage(edgeLength: 200, url: URL(string: "https://raw.githubusercontent.com/q231950/rorschach/main/Resources/rorschach.png")) { edgeLength in
                        Color.gray.opacity(0.1)
                            .frame(width: edgeLength, height: edgeLength, alignment: .center)
        }
    }
}
#endif
