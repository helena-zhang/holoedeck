import SwiftUI

class SharedViewModel: ObservableObject {
    @Published var prompt: String = ""
}
