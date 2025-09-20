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

struct BookmarkDetailView<ViewModel: BookmarkViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
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
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.showsDeleteConfirmation.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("delete bookmark button")
                    .confirmationDialog("Are you sure you want to delete the bookmark?", isPresented: $viewModel.showsDeleteConfirmation) {
                        Button(action: {
                            Task {
                                viewModel.delete()
                            }
                        }, label: {
                            Text("delete bookmark button", bundle: .module)
                        })

                        Button(action: {
                            viewModel.showsDeleteConfirmation = false
                        }, label: {
                            Text("cancel delete bookmark button", bundle: .module)
                        })
                    }
                }
            }
        }
    }
}
