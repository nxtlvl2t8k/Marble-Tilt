//
//  MoreView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-12.
//


import SwiftUI
import MessageUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingMail = false
    @State private var showingMessage = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var messageResult: MessageComposeResult? = nil
    @State private var showActivityView = false
    
    private let shareText = """
    Check out Marble Tilt App

    http://itunes.apple.com/us/app/prince-george-transit/id558331296?mt=8
    """
    private let shareURL = URL(string: "http://itunes.apple.com/us/app/prince-george-transit/id558331296?mt=8")!
    private let developerEmail = "hugeholdings@hotmail.com"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Marble Tilt").font(.headline)) {
                    Button("Share via SMS") {
                        showingMessage = true
                    }
                    Button("Share on Social") {
                        showActivityView = true
                    }
                    Button("Send Email") {
                        showingMail = true
                    }
                }
                
                Section(header: Text("Invite to Marble Tilt").font(.headline)) {
                    Button("Open App Store") {
                        UIApplication.shared.open(shareURL)
                    }
                    Button("Send Bug Report Email") {
                        showingMail = true
                    }
                }
            }
            .navigationTitle("More Info")
            .sheet(isPresented: $showingMail) {
//                MailView(isShowing: $showingMail,
//                         result: $mailResult,
//                         subject: "Check out 'Marble Tilt' on App Store !",
//                         recipients: [developerEmail],
//                         messageBody: shareText)
//            }
//            .sheet(isPresented: $showingMessage) {
//                MessageView(isShowing: $showingMessage,
//                            result: $messageResult,
//                            body: shareText)
//            }
//            .sheet(isPresented: $showActivityView) {
//                ActivityView(activityItems: [shareText, shareURL])
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Close") { dismiss() }
                .padding()
        }

    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
