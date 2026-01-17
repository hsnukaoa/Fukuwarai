//
//  ContentView.swift
//  Fukuwarai
//
//  Created by 宇田川航太 on 2026/01/17.
//

import SwiftUI
import ARKit

struct ContentView: View {
    @State private var smileScore: Double? = nil
    @State private var isDetecting = false
    @State private var arSession = ARSession()
    @State private var smileStartTime: Date? = nil
    @State private var shouldNavigate = false
    private let smileDelegate = SmileCheck()
    
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var faceParts: [FaceParts] = []
    @State private var partsLocation: [CGPoint] = [CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero]
    
    func startSmileDetection() {
        smileDelegate.onSmileUpdate = { score in
            DispatchQueue.main.async {
                self.smileScore = score
                
                if score > 0.6 {
                    if self.smileStartTime == nil {
                        self.smileStartTime = Date()
                    } else if let start = self.smileStartTime, Date().timeIntervalSince(start) >= 2 {
                        self.arSession.pause()
                        self.isDetecting = false
                        self.shouldNavigate = true
                        showCamera = true
                        partsLocation = [.zero, .zero, .zero, .zero]
                    }
                } else {
                    self.smileStartTime = nil
                }
            }
        }
        
        arSession.delegate = smileDelegate
        let configuration = ARFaceTrackingConfiguration()
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isDetecting = true
    }
    
    var body: some View {
        if let _ = capturedImage{
            AfterCaptureUI(faceParts: faceParts)
        }
        
        VStack(spacing: 20) {
            if smileScore ?? 0 > 0.6 {
                Text("そのまま笑顔を保ってください")
                    .font(.title)
            } else {
                Text(isDetecting ? "笑顔になってください" : "")
            }
            
            Button {
                startSmileDetection()
            }label: {
                Label("福笑いを開始", systemImage: "camera.fill")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .sheet(isPresented: $showCamera) {
                CameraViewControllerRepresentable(capturedImage: $capturedImage, faceParts: $faceParts)
            }
            .buttonStyle(.plain)
        }
        .padding()
        
    }
}

#Preview {
    ContentView()
}
