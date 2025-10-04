//
//  ErrorView.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 03.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Utilities

struct AccountErrorView: View {
    let viewModel: WidgetState.AccountInfoViewModel
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    private var text: String {
        let text: String
        if viewModel.accountsCount == 0 {
            // user has no accounts at all
            switch widgetFamily {
            case .systemSmall:
                text = "no account"
            default:
                text = "no account long"
            }
        } else if viewModel.accountsCount == 1 && viewModel.activatedAccountsCount == 0 {
            // user has exactly one account which is not activated
            switch widgetFamily {
            case .systemSmall:
                text = "account not active"
            default:
                text = "account not active long"
            }
        } else {
            // user has several accounts but none is activated
            switch widgetFamily {
            case .systemSmall:
                text = "no active accounts"
            default:
                text = "no active accounts long"
            }
        }

        return text.localized
    }

    private var padding: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 10
        default:
            return 20
        }
    }

    var body: some View {
        VStack {
            Spacer()

            Text(text.localized)
                .font(.body)

            Spacer()
            HStack(alignment: .bottom) {
                Spacer()

                Image(systemName: "book")
            }
        }
        .applyBackground()
    }
}
