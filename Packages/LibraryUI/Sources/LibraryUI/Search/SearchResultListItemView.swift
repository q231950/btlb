//
//  SearchResultListItemView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 15.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import SwiftUI
import LibraryCore

public struct SearchResultListItemView: View {

    let result: SearchResultListItemModel
    let action: (SearchResultListItemModel) -> Void

    public init(result: SearchResultListItemModel, action: @escaping (SearchResultListItemModel) -> Void) {
        self.result = result
        self.action = action
    }

    public var body: some View {
        ZStack {

            Button(action: {
                action(result)
            }) {
                HStack {
                    HStack(alignment: .top) {
                        if result.library.isPublicHamburg {
                            loadImage(result.imageUrl)
                        }

                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.title3)
                                .bold()

                            Text(result.subtitle)
                                .font(.subheadline)
                        }
                    }

                    Spacer()
                }
                .padding([.top, .bottom], 18)
                .multilineTextAlignment(.leading)
            }
        }
    }

    @ViewBuilder
    private func loadImage(_ url: URL?) -> some View {
        AsyncImage(url: result.imageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .frame(width: 60, height: 90, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#if DEBUG
struct SearchResultListItem_Previews: PreviewProvider {
    static var previews: some View {
        let result1 = SearchResultListItemModel(
            library: LibraryModel(
                name: "Central Library",
                subtitle: "The very central library",
                identifier: "abc",
                baseUrl: nil,
                catalogUrl: nil
            ),
            identifier: "identifier",
            title: "Neuromancer",
            subtitle: "subtitle",
            number: "number",
            imageUrl: URL(string: "https://cover.ekz.de/9783869641140.jpg")
        )

        Group {
            SearchResultListItemView(result: result1) { _ in }
                .previewLayout(PreviewLayout.sizeThatFits)

            SearchResultListItemView(result: result1) { _ in }
                .previewLayout(PreviewLayout.sizeThatFits)
                .preferredColorScheme(.dark)
        }
        .accentColor(.primary)
    }
}
#endif
