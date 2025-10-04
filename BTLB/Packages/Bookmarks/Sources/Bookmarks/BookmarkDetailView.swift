//
//  BookmarkDetailView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.02.23.
//

import Foundation
import SwiftUI

import LibraryUI
import Utilities
import Localization

struct BookmarkDetailView: View {

    private var viewModel: BookmarkViewModelProtocol

    init(viewModel: BookmarkViewModelProtocol) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                if let imageUrl = self.viewModel.bookmark.bookmarkImageUrl {
                    BlurredAsyncImage(edgeLength: proxy.size.width, url: URL(string: imageUrl)) { _ in
                        EmptyView()
                    }
                }

                if let title = self.viewModel.bookmark.bookmarkTitle {
                    HStack {
                        Text(title)
                            .font(.title)
                            .padding([.leading, .trailing, .bottom], 20)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                }

                if let author = self.viewModel.bookmark.bookmarkAuthor {
                    HStack {
                        Text(author)
                            .font(.headline)
                            .padding([.leading, .trailing, .bottom], 20)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                }

                ForEach(viewModel.bookmark.infos, id: \.self) { info in
                    PairView(key: info.title.localized, value: info.value)
                }

                deleteButton
            }
            .navigationBarItems(trailing: trailingBarItems)
        }
    }

    @ViewBuilder private var trailingBarItems: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                doneButton
            }
        }
    }

    @ViewBuilder private var doneButton: some View {
        Button(action: {
            viewModel.dismiss()
        }) {
            Text("Done", bundle: .localization)
        }
    }

    @ViewBuilder private var deleteButton: some View {
        Button(action: {
            viewModel.delete()
        }) {
            Text("delete bookmark button", bundle: .module)
                .foregroundColor(.red)
        }
    }
}
