import SwiftUI

@main
struct GalleryApp: App {
    @StateObject private var viewModel = SharedViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.volumetric)
//        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)

        ImmersiveSpace(id: "Environment") {
            ImmersiveView()
                .environmentObject(viewModel) 
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}

