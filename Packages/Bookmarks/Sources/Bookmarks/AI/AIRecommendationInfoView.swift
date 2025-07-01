//
//  AIRecommendationInfoView.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 06.06.25.
//

import SwiftUI
import LibraryUI
import Localization
import BTLBSettings

struct AIRecommendationInfoView: View {

    @State private var showsMailComposeView = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How AI Book Recommendation Works", bundle: .module)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                
                Text("AI Recommender Description", bundle: .module)
                    .font(.body)
                
                Spacer()

                RoundedButton(style: .secondary) {
                    showsMailComposeView.toggle()
                } _: {
                    Text("Feedback")
                }

            }
            .padding()
            .navigationTitle("Recommender Title".localized(bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showsMailComposeView) {
                MailComposerWrapperView(
                    subject: "Recommender Feedback Email Subject".localized(bundle: .module),
                    messageBody: message,
                    recipients: ["support@btlb.app"],
                    isHTML: true
                )
            }
        }
    }
    
    var message: String {
        """
        <html>
        <head>
            <style>
                body {
                    font-family: Menlo, Monaco, 'Courier New', monospace;
                    font-size: 14px;
                    line-height: 1.6;
                    color: #333333;
                    margin: 20px;
                    background-color: #f8f9fa;
                }
                .header {
                    font-weight: bold;
                    font-size: 16px;
                    color: #007AFF;
                    margin-bottom: 15px;
                }
                .section {
                    margin-bottom: 20px;
                    padding: 15px;
                    background-color: #ffffff;
                    border-radius: 8px;
                    border-left: 4px solid #007AFF;
                }
                .label {
                    font-weight: bold;
                    color: #555555;
                }
                .code {
                    background-color: #f1f3f4;
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-family: Menlo, Monaco, 'Courier New', monospace;
                }
            </style>
        </head>
        <body>
            <div class="header">\("Feedback Email: AI Recommender Feedback".localized(bundle: .module))</div>
            
            <div class="section">
                <div class="label">\("Feedback Email: Issue Description".localized(bundle: .module))</div>
                <p>\("Feedback Email: Please describe the issue you encountered with the AI Recommender".localized(bundle: .module))</p>
                <br><br>
            </div>
            
            <div class="section">
                <div class="label">\("Feedback Email: Additional Information".localized(bundle: .module))</div>
                <p>App Version: <span class="code">BTLB v\(VersionNumberProvider.versionString)</span></p>
                <p>\("Feedback Email: Any other relevant details".localized(bundle: .module))</p>
                <br><br>
            </div>
        </body>
        </html>
        """
    }
}

#Preview {
    AIRecommendationInfoView()
        .environment(\.locale, Locale(identifier: "de"))
}

#Preview("Email Content") {
    let nsAttributedString = try! NSAttributedString(data: Data(AIRecommendationInfoView().message.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    let attributedString = try! AttributedString(nsAttributedString, including: \.uiKit)
    Text(attributedString)
        .environment(\.locale, Locale(identifier: "de"))
}
