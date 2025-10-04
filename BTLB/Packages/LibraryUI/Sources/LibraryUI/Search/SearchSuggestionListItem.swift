//
//  SearchSuggestionListItem.swift
//  
//
//  Created by Martin Kim Dung-Pham on 01.04.22.
//

import Foundation
import SwiftUI
import LibraryCore
import Localization

public struct SearchSuggestionListItem: View {

    private let suggestion: SearchSuggestionModel
    private let onSelect: (() -> Void)?
    private let onDelete: (() -> Void)?
    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d, H:mm:ss", options: 0, locale: NSLocale.current)

        return df
    }()

    public init(_ suggestion: SearchSuggestionModel, onSelect: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.suggestion = suggestion
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button(action: {
                    onSelect?()
                }) {
                    Text(suggestion.searchTerm)
                        .font(.headline)
                        .padding(.bottom, 5)
                }

                Spacer()

                Button(action: {
                    onDelete?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            HStack {
                Text(suggestion.date, formatter: dateFormatter)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                Text(Localization.Search.Text.searchHits(suggestion.resultsCount))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding([.top, .bottom], 10)    

    }
}

#if DEBUG
struct SearchSuggestionListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SearchSuggestionListItem(SearchSuggestionModel(searchTerm: "Die drei Sonnen Die drei Sonnen Die drei Sonnen Die drei Sonnen", date: Date(), resultsCount: 23))

            SearchSuggestionListItem(SearchSuggestionModel(searchTerm: "Die drei Sonnen", date: Date(), resultsCount: 23))
        }
            .preferredColorScheme(.light)
//            .previewLayout(.fixed(width: 340, height: 100))
    }
}
#endif
