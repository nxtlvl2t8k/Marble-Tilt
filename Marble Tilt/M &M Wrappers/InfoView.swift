//
//  MoreView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-12.
//


import SwiftUI
import MessageUI

//struct AppInfo: Identifiable {
//    let id = UUID()
//    let name: String
//    let url: URL
//}

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
//    @State private var selectedApp: AppInfo? = nil
//    @State private var showingRandomApp = false
    
    @State private var showingMail = false
    @State private var showingMessage = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var messageResult: MessageComposeResult? = nil
//    @State private var showActivityView = false
    
    private let shareText = """
    Check out Marble Tilt App

    https://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8
    """
    
//    private let apps: [AppInfo] = [
//         AppInfo(name: "Marble Tilt", url: URL(string: "https://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8")!),
//         AppInfo(name: "WinterLand Scratcher", url: URL(string: "https://apps.apple.com/ca/app/winterland-scratcher/id1054185804?mt=8")!),
//         AppInfo(name: "Itripoley", url: URL(string: "https://apps.apple.com/ca/app/itripoley/id1586541611?mt=8")!)
//     ]

//    private let shareURL = URL(string: "https://apps.apple.com/ca/developer/huge-holdings-ltd/id508584861?mt=8")!
//    private let developerEmail = "hugeholdings@hotmail.com"
    
    private let shareURL = URL(string: "http://itunes.apple.com/us/app/prince-george-transit/id558331296?mt=8")!
        private let mailSubject = "Check out 'PG Transit' on App Store!"
        private let bugMailSubject = "PG Transit Report"
        private let developerEmail = "yingmu52@gmail.com"
          
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Prince George Transit")) {
                    Button("Share via SMS") {
                        showingMessage = true
                    }
                    Button("Send Email") {
                        showingMail = true
                    }
                }
                
                Section(header: Text("Invite to PG Transit")) {
                    Button("Open App Store") {
                        UIApplication.shared.open(shareURL)
                    }
                }
                
                Section(header: Text("Feedback")) {
                    Button("Send Bug Report Email") {
                        showingMail = true
                    }
                }
            }
            .navigationTitle("More Info")
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
