//
//  MeditateWelcomeView.swift
//  Gallery
//
//  Created by Helena Zhang on 2/17/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities
import UniformTypeIdentifiers

struct ExploreActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Explore Environment Together"
        metadata.type = .generic
        metadata.sceneAssociationBehavior = .content("Environment")
        return metadata
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItemsConfiguration: UIActivityItemsConfiguration
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItemsConfiguration: activityItemsConfiguration)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareSheetView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct MeditateWelcomeView: View {
    @Binding var immersiveSpaceActive: Bool
    @Binding var prompt: String
    @Binding var showingShareSheet: Bool
    
    @State private var choice: String = "Exist"
    @Environment(\.openWindow) private var openWindow
    let choices = ["Exist", "Hear Sound"]
    @Environment(\.dismiss) private var dismiss
    var exitEnvironment: () -> Void
    @State private var showBreathingAnimation = false
    
    var body: some View {
        
        
//                    VStack {
//                Text("Do you want to exist or listen to sound?")
//                Picker("Choose an option:", selection: $choice) {
//                    ForEach(choices, id: \.self) { choice in
//                        Text(choice).tag(choice)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()
//                        Button("Continue") {
//                            dismiss();
//                            openWindow(id: "Breathing")
//                        }
                        
                        Button("Share and Start Watch Together") {
                            print("Attempting to present share sheet...")
                                self.showingShareSheet = true
                        }
                        .sheet(isPresented: $showingShareSheet) {
                            self.shareSheet()
                        }
                        

//                Button("Exit Environment") {
//                    exitEnvironment()
//                }
            }
//    }
    
    func shareSheet() -> some View {
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(ExploreActivity())
        
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        
        return ActivityView(activityItemsConfiguration: configuration)
    }
}
