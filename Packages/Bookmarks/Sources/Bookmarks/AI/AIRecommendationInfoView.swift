//
//  AIRecommendationInfoView.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 06.06.25.
//

import SwiftUI
import LibraryUI
import BTLBSettings

struct AIRecommendationInfoView: View {

    @State private var showsMailComposeView = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How AI Recommender Works")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 8)
                
                Text("The recommender uses a large language model (LLM) to suggest books based on your selection of bookmarks. In order to provide suggestions the _title_ and _author_ of each selected item is sent to an LLM provider. If you feel uncomfortable with submitting data to the LLM provider you can turn off the Recommender feature in the settings section of the app. Please also note that because of the nature of LLMs the suggestions may contain unexpected content – there may even be recommendations of books which do not exist. Please be aware of this and send feedback in case of unexpected results.")
                    .font(.body)
                
                Spacer()

                RoundedButton(style: .secondary) {
                    showsMailComposeView.toggle()
                } _: {
                    Text("Feedback")
                }

            }
            .padding()
            .navigationTitle("✨ Recommender")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showsMailComposeView) {
                MailComposerWrapperView(subject: "Recommender Feedback", messageBody: message, recipients: ["support@btlb.app"], isHTML: true)
            }
        }
    }

    private var message: String {
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
            <div class="header">AI Recommender Feedback</div>
            
            <div class="section">
                <div class="label">Issue Description:</div>
                <p>Please describe the issue you encountered with the AI Recommender:</p>
                <br><br>
            </div>
            
            <div class="section">
                <div class="label">Expected Behavior:</div>
                <p>What did you expect to happen?</p>
                <br><br>
            </div>
            
            <div class="section">
                <div class="label">Actual Behavior:</div>
                <p>What actually happened? If you received unexpected book recommendations, please list them:</p>
                <br><br>
            </div>
            
            <div class="section">
                <div class="label">Steps to Reproduce:</div>
                <p>1. </p>
                <p>2. </p>
                <p>3. </p>
            </div>
            
            <div class="section">
                <div class="label">Additional Information:</div>
                <p>App Version: <span class="code">BTLB v\(VersionNumberProvider.versionString)</span></p>
                <p>Any other relevant details:</p>
                <br><br>
            </div>
        </body>
        </html>
        """
    }
}

#Preview {
    AIRecommendationInfoView()
}
