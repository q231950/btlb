//
//  ItemAvailabilityListView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 05.12.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import LibraryCore

public struct ItemAvailabilityListView: View {

    @State var availability: ItemAvailability?

    public var body: some View {
        NavigationView {
            Group {
                if let availabilities = availability?.availabilities {
                    List {
                        ForEach(availabilities) { availability in
                            AvailabilityItemView(availability: availability)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                } else {
                    Text("No availability information available.")
                }
            }
            .navigationTitle("Availabilities")
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
        }
    }
}

#Preview {
    ItemAvailabilityListView(availability: ItemAvailability.stub)
}

private extension ItemAvailability {
    static var stub: ItemAvailability {
        .init(
            availabilities: [
                .available(Location(name: "Library 1")),
                .available(Location(name: "Library 2")),
                .notAvailable(Location(name: "Library 3")),
                .unknown(Location(name: "Library 4"))
            ]
        )
    }
}
