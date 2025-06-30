//
//  MailComposerWrapperView.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 30.06.25.
//

import MessageUI
import SwiftUI

struct MailComposerWrapperView: UIViewControllerRepresentable {
    let subject: String
    let messageBody: String
    let recipients: [String]
    let isHTML: Bool

    @Environment(\.dismiss) private var dismiss

    init(subject: String = "", messageBody: String = "", recipients: [String] = [], isHTML: Bool = false) {
        self.subject = subject
        self.messageBody = messageBody
        self.recipients = recipients
        self.isHTML = isHTML
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: isHTML)
        mailComposer.setToRecipients(recipients)
        return mailComposer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerWrapperView
        
        init(_ parent: MailComposerWrapperView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}
