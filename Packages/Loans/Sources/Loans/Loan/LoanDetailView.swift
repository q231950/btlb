//
//  LoanDetail.swift
//  
//
//  Created by Martin Kim Dung-Pham on 18.08.22.
//

import Foundation
import StoreKit
import SwiftUI

import BTLBSettings
import LibraryCore
import LibraryUI
import Localization
import Utilities

public struct LoanDetailView<ViewModel: LibraryCore.LoanViewModel>: View {

    @ObservedObject private var viewModel: ViewModel
    @Environment(\.requestReview) private var requestReview
    private var dismiss: @MainActor () -> Void

    public init(_ viewModel: ViewModel, dismiss: @MainActor @escaping () -> Void) {
        self.viewModel = viewModel
        self.dismiss = dismiss
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                ExpirationNotificationView(viewModel.notificationDescription)

                if let url = viewModel.loan.iconUrl, !url.isEmpty {
                    BlurredAsyncImage(edgeLength: proxy.size.width, url: URL(string: url)) { _ in
                        EmptyView()
                    }
                }

                HStack {
                    Text("\(viewModel.loan.title) - \(viewModel.loan.subtitle)")
                        .font(.headline)
                        .padding(20)

                    Spacer()
                }

                PairView(key: "Loaned until".localized, value: viewModel.loan.dueDate.formatted(date: .long, time: .omitted))

                PairView(key: "Prolonged".localized, value: "\(viewModel.loan.renewalCount)")

                PairView(key: "Reservations".localized, value: viewModel.lockedByPreorderDescription)

                PairView(key: "Volume No.".localized, value: viewModel.loan.volume ?? "n\\a")
                PairView(key: "Barcode".localized, value: viewModel.loan.barcode)

                PairView(key: "Shelf Mark".localized, value: viewModel.loan.shelfmark)

                ForEach(viewModel.loan.infos) {
                    PairView(key: $0.title.localized, value: $0.value)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(viewModel.loan.title)
            .toolbar {
                if #available(iOS 26.0, *) {
                    toolbarx
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Task {
                                await viewModel.toggleBookmarked()
                            }
                        } label: {
                            if viewModel.isBookmarked {
                                Image(systemName: "bookmark.fill")
                                    .accessibilityLabel(Text(Localization.Loans.Accessibility.removeBookmark))
                            } else {
                                Image(systemName: "bookmark")
                                    .accessibilityLabel(Text(Localization.Loans.Accessibility.bookmark))
                            }
                        }
                    }

                    ToolbarItem {
                        ProgressButton(state: viewModel.progressButtonState) {
                            viewModel.showsRenewalConfirmation = true
                        }
                        .accessibilityLabel(Text(renewButtonAccessibilityLabel))
                        .disabled(!viewModel.loan.canRenew)
                        .confirmationDialog(Localization.Detail.renewalConfirmationTitle, isPresented: $viewModel.showsRenewalConfirmation) {
                            Button(action: {
                                Task {
                                    try await viewModel.renew()
                                }
                            }, label: {
                                Text(Localization.Detail.renewalConfirmationRenewButtonTitle)
                            })

                            Button(role: .cancel, action: {
                                viewModel.showsRenewalConfirmation = false
                            }, label: {
                                Text(Localization.Detail.renewalConfirmationCancelButtonTitle)
                            })
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("Done".localized)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.updateAsyncProperties()
            }
            .perform(requestReview, onChangeOf: $viewModel.shouldRequestAppReview)
        }
    }

    @available(iOS 26.0, *)
    @ToolbarContentBuilder var toolbarx: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                Task {
                    await viewModel.toggleBookmarked()
                }
            } label: {
                if viewModel.isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .accessibilityLabel(Text(Localization.Loans.Accessibility.removeBookmark))
                } else {
                    Image(systemName: "bookmark")
                        .accessibilityLabel(Text(Localization.Loans.Accessibility.bookmark))
                }
            }
        }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .topBarLeading) {
            ProgressButton(state: viewModel.progressButtonState) {
                viewModel.showsRenewalConfirmation = true
            }
            .accessibilityLabel(Text(renewButtonAccessibilityLabel))
            .disabled(!viewModel.loan.canRenew)
            .confirmationDialog(Localization.Detail.renewalConfirmationTitle, isPresented: $viewModel.showsRenewalConfirmation) {
                Button(action: {
                    Task {
                        try await viewModel.renew()
                    }
                }, label: {
                    Text(Localization.Detail.renewalConfirmationRenewButtonTitle)
                })

                Button(role: .cancel, action: {
                    viewModel.showsRenewalConfirmation = false
                }, label: {
                    Text(Localization.Detail.renewalConfirmationCancelButtonTitle)
                })
            }
        }

        ToolbarSpacer(.flexible)

        ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task {
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }) {
                    Text("Done".localized)
                }
            }
    }

    private var renewButtonAccessibilityLabel: LocalizedStringKey {
        if case ProgressButtonState.success = viewModel.progressButtonState {
            return LocalizedStringKey(Localization.Loans.Accessibility.renewed)
        } else if viewModel.loan.canRenew {
            return LocalizedStringKey(Localization.Loans.Accessibility.renew)
        } else {
            return LocalizedStringKey(Localization.Loans.Accessibility.notRenewable)
        }
    }
}

struct RequestAppReviewViewModifier: ViewModifier {
    @Binding var shouldRequestAppReview: Bool
    var action: RequestReviewAction

    private var appReviewService: LibraryCore.AppReviewService {
        BTLBSettings.AppReviewService(userDefaults: .suite)
    }

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            return content
                .onChange(of: shouldRequestAppReview) { oldValue, newValue in
                    if newValue == true && appReviewService.shouldRequestAppReview {
                        action()
                        appReviewService.resetAppReviewRequestIndicators()
                    }
                }
        } else {
            return content
                .onChange(of: shouldRequestAppReview, perform: { value in
                    if value == true && appReviewService.shouldRequestAppReview {
                        action()
                        appReviewService.resetAppReviewRequestIndicators()
                    }
            })
        }
    }
}

extension View {
    func perform(_ action: RequestReviewAction, onChangeOf value: Binding<Bool>) -> some View {
        self.modifier(RequestAppReviewViewModifier(shouldRequestAppReview: value, action: action))
    }
}

//#Preview {
//    Text("Hello, world!")
//        .modifier(OnChangeViewModifier(shouldRequestAppReview: .constant(true), action: RequestReviewAction))
//}

#if DEBUG
import LibraryCore

struct NotificationSchedulerMock: NotificationScheduling {

    func authorized() async -> Bool {
        true
    }

    func shouldScheduleNotifications(notificationsEnabled: Bool) async -> Bool {
        true
    }

    public func hasDeliveredAccountUpdateNotification() async  -> Bool {
        false
    }

    func scheduleNotification(for: LibraryCore.NotificationType, index: Int?) async {
        // does nothing when scheduling
    }

    func pendingNotificationTriggerDate(for barcode: String) async -> Date? {
        scheduledNotificationDates[barcode]
    }

    func removeAllNotifications() async {
    }

    func removeAllNotifications(for types: [NotificationType]) async {
    }

    func removeStatusNotifications(for items: [LibraryCore.RenewableItem]) async {
    }

    var scheduledNotificationDates: [String: Date]
}

class LoanStub: Loan {
    static func == (lhs: LoanStub, rhs: LoanStub) -> Bool {
        lhs.barcode == rhs.barcode
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(barcode)
    }

    static let stub1 = LoanStub(libraryIdentifier: "HAMBURG_PUBLIC",
                                title: "Snow Crash",
                                subtitle: "When the computer crashed and wrote gibberish into the bitmap, the result was something that looked vaguely like static on a broken television set—a 'snow crash'",
                                dueDate: .distantFuture,
                                shelfmark: "SNO",
                                iconUrl: "https://www.hugendubel.info/annotstream/9783104913384/COP",
                                renewalCount: 1,
                                canRenew: true,
                                renewalToken: nil,
                                lockedByPreorder: true,
                                barcode: "123456789",
                                infos: [Info(title: "Language", value: "English")])

    internal init(
        libraryIdentifier: String,
        author: String? = nil,
        title: String,
        subtitle: String,
        dueDate: Date,
        shelfmark: String,
        iconUrl: String? = nil,
        renewalCount: Int,
        canRenew: Bool,
        renewalToken: String?,
        lockedByPreorder: Bool,
        volume: String? = nil,
        barcode: String,
        infos: [LibraryCore.Info],
        notificationScheduledDate: Date? = nil
    ) {
        self.libraryIdentifier = libraryIdentifier
        self.author = author
        self.title = title
        self.subtitle = subtitle
        self.dueDate = dueDate
        self.shelfmark = shelfmark
        self.iconUrl = iconUrl
        self.renewalCount = renewalCount
        self.canRenew = canRenew
        self.renewalToken = renewalToken
        self.lockedByPreorder = lockedByPreorder
        self.volume = volume
        self.barcode = barcode
        self.infos = infos
        self.notificationScheduledDate = notificationScheduledDate
    }

    var libraryIdentifier: String

    var author: String?

    var title: String

    var subtitle: String

    var dueDate: Date

    var shelfmark: String

    var iconUrl: String?

    var renewalCount: Int

    var canRenew: Bool

    var renewalToken: String?

    var lockedByPreorder: Bool

    var volume: String?

    var barcode: String

    var infos: [LibraryCore.Info]

    var notificationScheduledDate: Date?
}

#Preview {
    NavigationStack {
        let viewModel = LoanViewModel(loanService: EnvironmentNoopLoanService.shared, 
                                      appReviewService: BTLBSettings.AppReviewService(userDefaults: UserDefaults.suite),
                                      notificationScheduler: NotificationSchedulerMock(scheduledNotificationDates: ["123456789": .now]),
                                      loan: LoanStub.stub1)
        viewModel.showsRenewalConfirmation = false
        
        return LoanDetailView(viewModel) {

        }
    }
}
#endif
