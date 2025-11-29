//
//  MoreView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-12.
//


import SwiftUI
import MessageUI

struct AboutUsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingMail = false
    @State private var showingMessage = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var messageResult: MessageComposeResult? = nil
    @State private var showActivityView = false
    
    private let shareText = """
    Check out Marble Tilt App

    https://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8
    """
    
    private let shareURL = URL(string: "https://apps.apple.com/ca/developer/huge-holdings-ltd/id508584861?mt=8")!
    private let developerEmail = "hugeholdings@hotmail.com"
    private let mailSubject = "Check out 'Marble Tilt' on App Store!"
    private let bugMailSubject = "Marble Tilt App Report"

    // Add your other apps here
    private let otherApps = [
//         "https://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8",
         "https://apps.apple.com/ca/app/bubbles-in-space/id1010801758?mt=8",
         "https://apps.apple.com/ca/app/winterland-scratcher/id1054185804?mt=8",
         "https://apps.apple.com/ca/app/itripoley/id1586541611?mt=8"
     ]
              
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
                    Button("Email Feedback (hugeholdings@hotmail.com)") {
                        showingMail = true
                    }
                }
                
                Section(header: Text("Check out more apps created by us").font(.headline)) {
                    Button("Open App Store (Random)") {
                        if let randomApp = otherApps.randomElement(),
                           let url = URL(string: randomApp) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("About Us")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMessage) {
                if MFMessageComposeViewController.canSendText() {
                    MessageComposeView(
                        body: shareText,
                        recipients: nil,
                        result: $messageResult
                    )
                } else {
                    Text("This device cannot send messages.")
                }
            }
            .sheet(isPresented: $showingMail) {
                if MFMailComposeViewController.canSendMail() {
                    MailComposeView(
                        subject: mailSubject,
                        body: shareText,
                        recipients: nil,
                        result: $mailResult
                    )
                } else {
                    Text("This device cannot send email.")
                }
            }
            .sheet(isPresented: $showActivityView) {
//                ActivityView(activityItems: [shareText])
                ShareSheet(activityItems: [shareText])
            }

        }
    }
}

//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}

