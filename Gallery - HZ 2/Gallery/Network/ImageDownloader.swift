import SwiftUI
import Foundation
import UIKit

class ImageDownloader: ObservableObject {
    @Published var downloadedCGImage: CGImage? = nil
    @Published var isLoading: Bool = false

    private var timer: Timer?
    private let statusBaseUrl = "https://backend.blockadelabs.com/api/v1/imagine/requests/"

    func initiateImageGeneration(with prompt: String) {
        guard let url = URL(string: "https://backend.blockadelabs.com/api/v1/skybox") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("8vDKfyJIX0EofpK3t7NCZ9ds78mq8nzPespmKSWxdsicx0mRRbzwG4HNvQFQ", forHTTPHeaderField: "x-api-key")
        request.addValue("true", forHTTPHeaderField: "enhance_prompt")
        request.addValue("9", forHTTPHeaderField: "skybox_style_id")

        
        let generationRequest = GenerationRequest(prompt: prompt)
        let jsonData = try? JSONEncoder().encode(generationRequest)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            let generationResponse = try? JSONDecoder().decode(InitiateResponse.self, from: data)
            // Handling the response
            self.checkImageStatus(id: generationResponse!.id)
        }
        task.resume()
    }

    func checkImageStatus(id: Int) {
        let statusCheckUrl = "\(statusBaseUrl)\(id)"
        guard let url = URL(string: statusCheckUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("8vDKfyJIX0EofpK3t7NCZ9ds78mq8nzPespmKSWxdsicx0mRRbzwG4HNvQFQ", forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            let responseString = String(data: data, encoding: .utf8)
                print("Received response: \(responseString ?? "nil")")
            do {
                let statusResponse = try JSONDecoder().decode(TopLevel.self, from: data)
                
                DispatchQueue.main.async {
                    if statusResponse.request.status == "complete" {
                        self?.downloadImage(urlString: statusResponse.request.fileUrl)
                    } else {
                        self?.timer?.invalidate() // Cancel any existing timer
                        self?.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                            self?.checkImageStatus(id: id)
                        }
                    }
                    
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }

    func downloadImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data), let cgImage = image.cgImage else {
                print(error?.localizedDescription ?? "Failed to download image")
                self?.isLoading = false
                return
            }

            DispatchQueue.main.async {
                self?.downloadedCGImage = cgImage
                self?.isLoading = false
            }
        }.resume()
    }
}

// Response models
struct InitiateResponse: Codable {
    let id: Int
}

struct StatusResponse: Codable {
    let status: String
    let file_url: String
}

// Define the Request model
struct Request: Codable {
    let id: Int
    let obfuscatedId: String
    let userId: Int
    let apiKeyId: Int
    let title: String
    let seed: Int
    let negativeText: String?
    let prompt: String
    let username: String
    let status: String
    let queuePosition: Int
    let fileUrl: String
    let thumbUrl: String
    let depthMapUrl: String
    let remixImagineId: Int?
    let remixObfuscatedId: String?
    let isMyFavorite: Bool
    let createdAt: String
    let updatedAt: String
    let errorMessage: String?
    let pusherChannel: String
    let pusherEvent: String
    let type: String
    let skyboxStyleId: Int
    let skyboxId: Int
    let skyboxStyleName: String
    let skyboxName: String
    let dispatchedAt: String
    let processingAt: String
    let completedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case obfuscatedId = "obfuscated_id"
        case userId = "user_id"
        case apiKeyId = "api_key_id"
        case title
        case seed
        case negativeText = "negative_text"
        case prompt
        case username
        case status
        case queuePosition = "queue_position"
        case fileUrl = "file_url"
        case thumbUrl = "thumb_url"
        case depthMapUrl = "depth_map_url"
        case remixImagineId = "remix_imagine_id"
        case remixObfuscatedId = "remix_obfuscated_id"
        case isMyFavorite = "isMyFavorite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case errorMessage = "error_message"
        case pusherChannel = "pusher_channel"
        case pusherEvent = "pusher_event"
        case type
        case skyboxStyleId = "skybox_style_id"
        case skyboxId = "skybox_id"
        case skyboxStyleName = "skybox_style_name"
        case skyboxName = "skybox_name"
        case dispatchedAt = "dispatched_at"
        case processingAt = "processing_at"
        case completedAt = "completed_at"
    }
}

// Define the top-level JSON structure
struct TopLevel: Codable {
    let request: Request
}

struct GenerationRequest: Codable {
    let prompt: String
}

struct GenerationResponse: Codable {
    let id: Int
    let status: String
    let file_url: String
}
