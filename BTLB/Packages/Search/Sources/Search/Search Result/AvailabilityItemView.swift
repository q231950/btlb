//
//  AvailabilityItemView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 05.12.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

import LibraryCore

struct AvailabilityItemView: View {
    let availability: Availability

    var body: some View {
        HStack {
            Image(systemName: availability.systemName)
            Text(availability.label, tableName: "Search", bundle: .module)
                .foregroundStyle(availability.textColor)

            Spacer()
        }
    }
}

private extension Availability {
    var label: LocalizedStringKey {
        switch self {
        case .available(let location): return "\(location.name): available"
        case .notAvailable(let location): return "\(location.name): not available"
        case .unknown(let location): return "\(location.name): unknown availability"
        }
    }

    var systemName: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .notAvailable: return "xmark.circle"
        case .unknown: return "questionmark.circle"
        }
    }

    var textColor: Color {
        switch self {
        case .available:
                .primary
        case .notAvailable:
                .secondary
        case .unknown:
                .primary
        }
    }
}

#Preview {
    AvailabilityItemView(availability: .available(Location(name: "Library 1")))

    AvailabilityItemView(availability: .notAvailable(Location(name: "Library 2")))

    AvailabilityItemView(availability: .unknown(Location(name: "Library 3")))
}
