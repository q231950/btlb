//
//  AccountChargesRows.swift
//
//
//  Created by Martin Kim Dung-Pham on 21.02.23.
//

import Foundation
import SwiftUI
import CoreData
import LibraryCore
import LibraryUI
import Localization
import Persistence
import Utilities

/// The charges of a single account, to be placed inside a list section:
/// a "Charges" label, one row per charge and then either the total or a hint that there are no charges.
public struct AccountChargesRows: View {
    @FetchRequest private var charges: FetchedResults<Persistence.Charge>

    /// - Parameter objectId: the managed object identifier of the account whose charges are shown
    public init(account objectId: NSManagedObjectID) {
        _charges = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(key: "date", ascending: true),
                NSSortDescriptor(key: "chargeDescription", ascending: true),
            ],
            predicate: NSPredicate(format: "chargeAccount == %@", objectId)
        )
    }

    private let chargesMocks: [MockCharge] = [
        MockCharge(reason: "Versäumnisgebühren", amount: 2.30),
        MockCharge(reason: "Versäumnisgebühren", amount: 4.20),
        MockCharge(reason: "Versäumnisgebühren", amount: 0.8),
    ]

    public var body: some View {
        ChargeRows(charges: charges.map { $0 }, sum: charges.map { $0 }.sum)
//        ChargeRows(charges: chargesMocks, sum: chargesMocks.map { $0 }.sum)
    }
}

protocol ChargeRepresentable {
    var amount: Int { get }
}

struct ChargeRows<ChargeType: LibraryCore.Charge>: View {

    let sum: Float?
    let charges: [ChargeType]

    init(charges: [ChargeType], sum: Float?) {
        self.charges = charges
        self.sum = sum
    }

    var body: some View {
        header

        list(of: charges)

        footer(sum: sum)
    }

    @ViewBuilder private var header: some View {
        Text(Localization.Titles.charges)
            .font(.subheadline)
            .bold()
            .foregroundStyle(.secondary)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder private func list(of charges: [ChargeType]) -> some View {
        ForEach(charges) { charge in
            HStack {
                charge.reason.map { text in
                    Group {
                        if charge.chargeAmount > 0 {
                            Text(text)
                        } else {
                            Text(text + Localization.Charges.Text.paid)
                        }
                    }
                }

                Spacer()

                Text("\(charge.chargeAmount, format: .currency(code: "EUR"))")
            }
            .font(.subheadline)
        }
    }

    @ViewBuilder private func footer(sum: Float?) -> some View {
        Group {
            if let sum {
                HStack {
                    Text(Localization.Charges.Text.sum)
                        .bold()
                    Spacer()
                    Text("\(sum, format: .currency(code: "EUR"))")
                        .bold()
                }
            } else {
                Text(Localization.Charges.Text.zeroCharges)
                    .font(.subheadline)
            }
        }
        .listRowSeparator(sum ?? 0 > 0 ? .visible : .hidden, edges: .top)
    }
}

let mockCharges = [
    MockCharge(reason: "Vormerkung", amount: 23.33),
    MockCharge(reason: "Vormerkung", amount: 12),
    MockCharge(reason: "Mahngebühren", amount: 0.4)
]

class MockCharge: LibraryCore.Charge {
    let amount: Float
    let reason: String?

    init(reason: String?, amount: Float) {
        self.reason = reason
        self.amount = amount
    }

    var chargeAmount: Float {
        amount
    }
}

struct ChargeRows_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section("abc") {
                ChargeRows(charges: [
                    MockCharge(reason: "Vormerkung", amount: 23),
                    MockCharge(reason: nil, amount: 12),
                    MockCharge(reason: "Vormerkung", amount: 0.4),
                ], sum: 42)
            }

            Section("def") {
                ChargeRows(charges: [
                    MockCharge(reason: "Vormerkung", amount: 0),
                    MockCharge(reason: "Vormerkung Vorkung Vormerkg ", amount: 20.33)
                ], sum: 30.33)
            }

            Section("def") {
                ChargeRows(charges: [
                    MockCharge(reason: "Vormerkung", amount: 0),
                    MockCharge(reason: "Vormerkung", amount: 0)
                ], sum: nil)
            }

            Section("Kim") {
                ChargeRows(charges: [MockCharge](), sum: nil)
            }
        }
    }
}
