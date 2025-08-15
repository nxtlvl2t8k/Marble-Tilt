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
                Section(header: Text("Share Current App").font(.headline)) {
                    Button("Share via SMS") {
                        showingMessage = true
                    }
                    Button("Send Email") {
                        showingMail = true
                    }
                }
                
                Section(header: Text("Discover more apps created by us").font(.headline)) {
                    Button("Open App Store") {
                        if let randomApp = apps.randomElement() {
                            selectedApp = randomApp
                        }
                        if let app = selectedApp {
                            Text("🎲 Selected: \(app.name)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button("Share Selected via SMS") {
                                showingMessage = true
                            }
                            Button("Share Selected via Email") {
                                showingMail = true
                            }
                            Button("Open in App Store") {
                                UIApplication.shared.open(app.url)
                            }
                        }
                    }
                }
                .navigationTitle("More Info")
                .sheet(isPresented: $showingMessage) {
                    if MFMessageComposeViewController.canSendText() {
                        MessageComposeView(
                            recipients: [],
                            body: selectedApp != nil ?
                                "Check out \(selectedApp!.name): \(selectedApp!.url.absoluteString)" :
                                "Check out Marble Tilt: https://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8",
                            result: $messageResult
                        )
                    }
                }
                .sheet(isPresented: $showingMail) {
                    if MFMailComposeViewController.canSendMail() {
                        MailComposeView(
                            subject: "Check out this app!",
                            body: selectedApp != nil ?
                                "I found a cool app: \(selectedApp!.name)\n\n\(selectedApp!.url.absoluteString)" :
                                "I found a cool app: Marble Tilt\n\nhttps://apps.apple.com/ca/app/marble-tilt/id1599878471?mt=8",
                            toRecipients: [],
                            result: $mailResult
                        )
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                Button("Close") { dismiss() }
                    .padding()
        }
        
//        List {
//            Section(header: Text("Our Apps").font(.headline)) {
//                Button("Open Random App") {
//                    if let randomApp = apps.randomElement() {
//                        selectedApp = randomApp
//                        showingRandomApp = true
//                    }
//                }
//            }
//        }
//        .alert(item: $selectedApp) { app in
//            Alert(
//                title: Text("Open \(app.name)?"),
//                message: Text("Do you want to go to the App Store for this app?"),
//                primaryButton: .default(Text("Yes"), action: {
//                    UIApplication.shared.open(app.url)
//                }),
//                secondaryButton: .cancel()
//            )
//        }
//        .navigationTitle("More Info")


    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
