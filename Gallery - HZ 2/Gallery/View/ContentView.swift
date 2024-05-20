import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var immersiveSpaceActive: Bool = false
    @State private var prompt: String = ""
    @EnvironmentObject var viewModel: SharedViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to The Gallery")
                .font(.system(size: 60, weight: .bold))
            Text("Where would you like to go?")
                .font(.system(size: 40, weight: .bold))
            
            TextField("Enter your dream art space here!", text: $prompt)
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(width: 800, height: 100)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(30)
            
            // Conditionally show "View Environment" button
            if !immersiveSpaceActive { // This button will be hidden once immersiveSpaceActive is true
                Button("View Environment") {
                    Task {
                        viewModel.prompt = prompt
                        _ = await openImmersiveSpace(id: "Environment")
                        immersiveSpaceActive = true
                    }
                }
            }
            
            if immersiveSpaceActive {
                Button("Exit Environment") {
                    Task {
                        await dismissImmersiveSpace()
                        immersiveSpaceActive = false
                    }
                }
                .background(Image("Gallery")) // Ensure the background modifier is correctly applied to a view
            }
        }
    }
}

// Preview provider if needed
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SharedViewModel())
    }
}
