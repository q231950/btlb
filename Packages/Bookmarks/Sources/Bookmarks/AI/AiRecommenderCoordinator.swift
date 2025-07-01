//
//  AiRecommenderCoordinator.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 01.07.25.
//

import SwiftUI
import ArchitectureX

import LibraryCore
import LibraryUI

class AiRecommenderCoordinator: Coordinator {
    var router: Router?

    let recommender: RecommenderProtocol
    let bookmarks: [any LibraryCore.Bookmark]

    init(recommender: RecommenderProtocol, bookmarks: [any LibraryCore.Bookmark]) {
        self.recommender = recommender
        self.bookmarks = bookmarks
    }

    var contentView: some View {
        AiRecommenderView(viewModel: .init(recommender, titles: bookmarks.compactMap { $0.bookmarkTitle }))
    }
}

class AiRecommenderViewModel: ObservableObject {
    let recommender: RecommenderProtocol
    let titles: [String]

    @Published var recommendation: Recommendation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(_ recommender: RecommenderProtocol, titles: [String]) {
        self.recommender = recommender
        self.titles = titles
    }

    @MainActor
    func loadRecommendations() async {
        guard !titles.isEmpty else {
            errorMessage = "No titles to recommend from"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            recommendation = try await recommender.recommendations(for: titles)
        } catch {
            errorMessage = "Failed to load recommendations: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

struct AiRecommenderView: View {
    @ObservedObject var viewModel: AiRecommenderViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if (viewModel.recommendation?.recommendations ?? []).isEmpty {
                emptyRecommendationsView
            } else {
                recommendationsView
            }
        }
        .navigationTitle("Recommender Title".localized(bundle: .module))
        .task {
            await viewModel.loadRecommendations()
        }
    }

    @ViewBuilder private var loadingView: some View {
        ProgressView()
            .padding()
        Text("Loading recommendations…", bundle: .module)
    }

    @ViewBuilder private var recommendationsView: some View {
        List {
            ForEach(viewModel.recommendation?.recommendations ?? [], id: \.self) { recommendation in
                VStack {
                    Text(recommendation.title)
                        .font(.headline)

                    Text(recommendation.author)
                        .font(.subheadline)
                }
            }
        }
    }

    @ViewBuilder private var emptyRecommendationsView: some View {
        Text("No recommendations found", bundle: .module)
            .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    AiRecommenderView(viewModel: AiRecommenderViewModel(MockRecommender(), titles: ["a", "b"]))
}

private class MockRecommender: RecommenderProtocol {
    func recommendations(for titles: [String]) async throws -> Recommendation {
        Recommendation(recommendations: [
            BookRecommendation(title: "Title 1", author: "Author 1"),
            BookRecommendation(title: "Title 2 This is long an longer and longer", author: "Author 2"),
            BookRecommendation(title: "Title 3", author: "Author 3 this is a veeery long author name"),
        ])
    }
}
