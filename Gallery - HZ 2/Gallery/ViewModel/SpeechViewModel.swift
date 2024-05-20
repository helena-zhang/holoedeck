//
//  SpeechViewModel.swift
//  Gallery
//
//  Created by Prabaljit Walia on 2/17/24.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizerViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var isListening: Bool = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startListening() {
        // Check authorization status
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.authorizationStatus = authStatus
                switch authStatus {
                case .authorized:
                    self.prepareForListening()
                default:
                    print("Speech recognition authorization was not granted.")
                    self.isListening = false
                }
            }
        }
    }

    private func prepareForListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        do {
            // Configure the audio session for the app.
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create and configure the speech recognition request.
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // Configure the audio engine and input node.
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            
            try audioEngine.start()
            
            // Start the speech recognition task.
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] result, error in
                var isFinal = false
                
                if let result = result {
                    self?.prompt = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self?.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self?.recognitionRequest = nil
                    self?.recognitionTask = nil
                    
                    self?.isListening = false
                }
            })
            
            isListening = true
        } catch {
            print("audioEngine couldn't start because of an error: \(error)")
            isListening = false
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        isListening = false
    }

}
