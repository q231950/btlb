//
//  SearchResultDetailView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 19.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import SwiftUI
import LibraryCore
import LibraryUI

enum BookmarkState {
    case loading
    case bookmarked(Bool)
}

struct SearchResultDetailView: View {
    @ObservedObject var viewModel: SearchResultInfoViewModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                if let url = self.viewModel.result.imageUrl {
                    BlurredAsyncImage(edgeLength: proxy.size.width, url: url) { edgeLength in
                        Color.gray.opacity(0.1)
                            .frame(width: edgeLength, height: edgeLength, alignment: .center)
                    }
                }

                HStack {
                    Text(self.viewModel.result.title)
                        .font(.title)
                        .padding([.leading, .trailing, .bottom], 20)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }

                HStack {
                    Text(self.viewModel.result.subtitle)
                        .font(.headline)
                        .padding([.leading, .trailing, .bottom], 20)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }

                if viewModel.loading {
                    ActivityIndicator(shouldAnimate: $viewModel.loading)
                } else {
                    if let details = viewModel.details {
                        ForEach(details.content, id: \.self) { pair in
                            PairView(key: pair.key.localized, value: pair.value)
                        }
                    }
                }
            }
            .onAppear(perform: {
                viewModel.updateBookmarkState()
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
#if swift(>=6.2)
                if #available(iOS 26.0, *) {
                    toolbarContent
                } else {
                    #endif
                    legacyToolbarContent
#if swift(>=6.2)
                }
                #endif
            }
        }
        .sheet(isPresented: $viewModel.showsAvailabilities) {
            ItemAvailabilityListView(availability: viewModel.details?.availability)
        }
    }

    @ToolbarContentBuilder var legacyToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            bookmarkButton
        }

        ToolbarItem(placement: .topBarLeading) {
            availabilitiesButton
        }

        ToolbarItem(placement: .topBarTrailing) {
            doneButton
        }
    }

#if swift(>=6.2)
    @available(iOS 26.0, *)
    @ToolbarContentBuilder var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            bookmarkButton
        }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .topBarLeading) {
            availabilitiesButton
        }

        ToolbarSpacer(.flexible)

        ToolbarItem(placement: .topBarTrailing) {
            doneButton
        }
    }
#endif

    @ViewBuilder private var bookmarkButton: some View {
        Group {
            if case .bookmarked(let bookmarked) = viewModel.bookmarkState {
                let title = bookmarked ? "bookmark.fill" : "bookmark"

                Button(action: {
                    viewModel.toggleBookmark()
                }) {
                    Image(systemName: title)
                }
                .accessibilityIdentifier("bookmark/unbookmark")
            } else {
                ProgressView()
            }
        }
    }

    @ViewBuilder private var availabilitiesButton: some View {
        Button {
            viewModel.showsAvailabilities.toggle()
        } label: {
            Image(systemName: availabilitiesButtonImageName)
        }
        .disabled(viewModel.details == nil)
        .tint(availabilitiesButtonTint)
    }

    private var availabilitiesButtonImageName: String {
        switch viewModel.availabilityStatus {
        case .noneAvailable:
            "checklist.unchecked"
        case .allAvailable:
            "checklist.checked"
        case .someAvailable:
            "checklist"
        }
    }

    private var availabilitiesButtonTint: Color {
        viewModel.details != nil ? .primary : .secondary
    }

    @ViewBuilder private var doneButton: some View {
        Button(action: {
            viewModel.dismiss()
        }) {
            Text("Done".localized)
        }
    }
}

#if DEBUG
struct SearchResultDetail_Previews: PreviewProvider {

    static var previews: some View {
        let result = SearchResultListItemModel(
            library: LibraryModel(name: "Central Library", subtitle: "The most central library", identifier: "abc-123", baseUrl: nil, catalogUrl: nil),
            identifier: "abc123",
            title: "Neuromancer",
            subtitle: "The fancy robot story",
            number: "number",
            imageUrl: URL(string: "https://cover.ekz.de/9783869641140.jpg")
        )

        return NavigationView {
            SearchResultDetailView(viewModel: SearchResultInfoViewModel(result: result, detailsProvider: MockSearchResultDetailsProviding()))
        }
    }
}

struct MockSearchResultDetailsProviding: SearchResultDetailsProviding {
    enum MockSearchResultDetailsProvidingError: Error {
        case mock
    }

    func details(for url: URL?, in library: LibraryModel) async throws -> any SearchResultDescribing {
        throw MockSearchResultDetailsProvidingError.mock
    }

    func status(availabilities: [LibraryCore.Availability], in library: LibraryModel) -> LibraryCore.AvailabilityStatus {
        .allAvailable
    }
}
#endif
