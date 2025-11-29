//
//  MessageComposeView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-08-15.
//
import SwiftUI
import MessageUI

struct MessageComposeView: UIViewControllerRepresentable {
    var body: String
    var recipients: [String]?
    @Binding var result: MessageComposeResult?
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        @Binding var result: MessageComposeResult?
        
        init(result: Binding<MessageComposeResult?>) {
            _result = result
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            defer { controller.dismiss(animated: true) }
            self.result = result
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.body = body
        if let recipients = recipients {
            vc.recipients = recipients
        }
        vc.messageComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}
