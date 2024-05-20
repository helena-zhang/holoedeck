import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @ObservedObject private var imageDownloader = ImageDownloader()
    @EnvironmentObject var viewModel: SharedViewModel

    // Placeholder CGImage
    let placeholderCGImage: CGImage = (UIImage(named: "gallery")?.cgImage)!

    var body: some View {
        Group {
            if let cgImage = imageDownloader.downloadedCGImage {
                // RealityView setup with cgImage
                RealityViewSetup(cgImage: cgImage)
            } else if imageDownloader.isLoading {
                Text("Loading environment...")
            } else {
                // RealityView setup with placeholderCGImage
                RealityViewSetup(cgImage: placeholderCGImage)
            }
        }
        .onAppear {
            imageDownloader.initiateImageGeneration(with: viewModel.prompt)
        }
    }
}

// Extracted RealityView setup to reuse for both downloaded and placeholder images
func RealityViewSetup(cgImage: CGImage) -> some View {
    RealityView { content in
        guard let texture = try? TextureResource.generate(from: cgImage, options: TextureResource.CreateOptions(semantic: nil)) else {
            fatalError("Failed to create texture")
        }
        let rootEntity = Entity()
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        rootEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))
        rootEntity.scale = .init(x: 1, y: 1, z: -1)
        let angle = Angle.degrees(90)
        let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
        rootEntity.transform.rotation = rotation
        content.add(rootEntity)
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
