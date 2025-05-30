//
//  ChargesAccountSection.swift
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

struct ChargesAccountSection: View {
    private let title: String
    private let subtitle: String
    @FetchRequest private var charges: FetchedResults<Persistence.Charge>

    public init(title: String, subtitle: String, account objectId: NSManagedObjectID) {
        self.title = title
        self.subtitle = subtitle
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

    var body: some View {
        ChargeSection(title, subtitle: subtitle, charges: charges.map { $0 }, sum: charges.map { $0 }.sum)
//        ChargeSection(title, subtitle: subtitle, charges: chargesMocks, sum: chargesMocks.map { $0 }.sum)
    }
}

protocol ChargeRepresentable {
    var amount: Int { get }
}

struct ChargeSection<ChargeType: LibraryCore.Charge>: View {

    let title: String
    let subtitle: String
    let sum: Float?
    let charges: [ChargeType]

    init(_ title: String, subtitle: String, charges: [ChargeType], sum: Float?) {
        self.title = title
        self.subtitle = subtitle
        self.charges = charges
        self.sum = sum
    }

    var body: some View {
        Section(content: {
            list(of: charges)

            footer(sum: sum)
        }, header: {
            header(title: title, subtitle: subtitle)
                .padding(.bottom, 10)
        })
    }

    @ViewBuilder private func header(title: String, subtitle: String) -> some View {
        ItemView(title: title,
                 subtitle2: subtitle,
                 subtitleSystemImageName: "building.columns")
        .listRowSeparator(.hidden)
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

struct ChargeSection_Previews: PreviewProvider {

    static var previews: some View {
        List {
            ChargeSection("abc",
                          subtitle: "Bücherhallen Hamburg",
                          charges: [
                            MockCharge(reason: "Vormerkung", amount: 23),
                            MockCharge(reason: nil, amount: 12),
                            MockCharge(reason: "Vormerkung", amount: 0.4),
                          ], sum: 42)

            ChargeSection("def",
                          subtitle: "Bücherhallen Hamburg",
                          charges: [
                            MockCharge(reason: "Vormerkung", amount: 0),
                            MockCharge(reason: "Vormerkung Vorkung Vormerkg ", amount: 20.33)
                          ], sum: 30.33)

            ChargeSection("def",
                          subtitle: "Bücherhallen Hamburg",
                          charges: [
                            MockCharge(reason: "Vormerkung", amount: 0),
                            MockCharge(reason: "Vormerkung", amount: 0)
                          ], sum: nil)

            ChargeSection("Kim",
                          subtitle: "Bücherhallen Hamburg Bücherhallen Hamburg Bücherhallen Hamburg",
                          charges: [MockCharge
            ](), sum: nil)
        }
    }
}
