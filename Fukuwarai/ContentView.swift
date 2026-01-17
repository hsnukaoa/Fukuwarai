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
        NavigationStack {
            VStack(spacing: 20) {
                if smileScore ?? 0 > 0.6 {
                    Text("😄 笑顔を検出しました！")
                        .font(.title)
                } else {
                    Text(isDetecting ? "笑顔を検出中..." : "まだ検出していません")
                }

                Button("笑顔検出を開始") {
                    startSmileDetection()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(isPresented: $shouldNavigate) {
                FukuwaraiView()
            }
        }
    }
}

#Preview {
    ContentView()
}
