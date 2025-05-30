//
//  ItemView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 09.02.23.
//

import Foundation
import LibraryCore
import SwiftUI

public extension BookmarkType {
    var systemImageName: String {
        self == .loan ? "tray.full" : "doc.text.magnifyingglass"
    }
}

public struct BadgeInfo {
    let systemImageName: String?

    public init(systemImageName: String?) {
        self.systemImageName = systemImageName
    }
}

public struct ItemView: View {

    let title: String
    let subtitle1: String?
    let subtitle2: String?
    let subtitleSystemImageName: String?
    let badgeInfo: BadgeInfo?

    public init(title: String, subtitle1: String? = nil, subtitle2: String? = nil, subtitleSystemImageName: String? = nil, badgeInfo: BadgeInfo? = nil) {
        self.title = title
        self.subtitle1 = subtitle1
        self.subtitle2 = subtitle2
        self.subtitleSystemImageName = subtitleSystemImageName
        self.badgeInfo = badgeInfo
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title3)
                .bold()
                .padding(.bottom, 1)

            subtitle1.map {
                Text($0)
                    .font(.subheadline)
            }

            subtitle2.map { text in
                Group {
                    Text(Image(systemName: subtitleSystemImageName ?? ""))
                        .font(.footnote)
                        .foregroundColor(.gray)
                    +
                    Text(" \(text)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 2)
            }
        }
        .badge(
            badgeInfo.map {
                Text("\(Image(systemName: $0.systemImageName ?? "questionmark.app"))")
            }
        )
    }
}

#if DEBUG
struct ItemViewProvider_Previews: PreviewProvider {

    static var previews: some View {
        List {
            ItemView(title: "Title",
                     subtitle1: "Subtitle 1",
                     subtitle2: "Subtitle 2",
                     subtitleSystemImageName: "calendar",
                     badgeInfo: .init(systemImageName: "bookmark"))

            ItemView(title: "Title",
                     subtitle1: "Subtitle 1")

            ItemView(title: "Title",
                     subtitle2: "Subtitle 2",
                     subtitleSystemImageName: "building.columns",
                     badgeInfo: .init(systemImageName: "bookmark.fill"))
        }
    }
}

#endif
