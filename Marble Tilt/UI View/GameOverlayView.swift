//
//  GameOverlayView.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//


import SwiftUI
import SpriteKit

//struct GameOverlayView: View {
//    @ObservedObject var viewModel: GameOverlayViewModel
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                
////                Button(action: {
////                    if viewModel.scene.editingMode {
////                        if let url = viewModel.scene.exportVortexLayout() {
////                            viewModel.showExportAlert(url: url)
////                        }
////                    } else {
////                        if viewModel.paidFeatureUnlocked {
////                            viewModel.toggleEditingMode()
////                        } else {
////                            viewModel.showUnlockAlert = true
////                        }
////                    }
////                }) {
////                    Text(viewModel.scene.editingMode ? "Save Layout" : "Edit Vortex")
//                Button(action: {
//                    if viewModel.paidFeatureUnlocked {
//                        viewModel.toggleEditingMode()
//                    } else {
//                        viewModel.showUnlockAlert = true
//                    }
//                }) {
//                    Text(viewModel.scene.editingMode ? "Exit Edit" : "Edit Vortex")
//                        .font(.headline)
//                        .padding(10)
//                        .background(viewModel.scene.editingMode ? Color.red : Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 4)
//                }
//                .padding()
//                .alert(isPresented: $viewModel.showUnlockAlert) {
//                    Alert(
//                        title: Text("Paid Feature"),
//                        message: Text("Editing vortex positions is a paid feature."),
//                        dismissButton: .default(Text("OK"))
//                    )
//                }
//                
////                Button("Load Custom Layout") {
////                    // Example: load the last saved layout
////                    let filename = "custom_vortex_layout.json"
////                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
////                        .appendingPathComponent(filename)
////                    
////                    if FileManager.default.fileExists(atPath: url.path) {
////                        viewModel.scene.loadVortexLayout(from: url)
////                    } else {
////                        print("❌ No saved layout found")
////                    }
////                }
////                .padding()
////                .background(Color.orange)
////                .foregroundColor(.white)
////                .cornerRadius(10)
//            }
//            Spacer()
//        }
//    }
//}
