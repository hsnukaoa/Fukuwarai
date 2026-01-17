//
//  HapticsManager.swift
//  Fukuwarai
//
//  Created by 宇田川航太 on 2026/01/18.
//

import SwiftUI
import CoreHaptics
import Combine

class HapticsManager: ObservableObject {
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private var isContinuousPlaying = false
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to start haptic engine")
                }
            }
        } catch {
            print("Haptics not available on this device")
        }
    }
    
    func playSuccessFeedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let Intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [Intensity, sharpness],
            relativeTime: 0
        )
        
        playPattern(events: [event])
    }
    
    func playPositionFeedback(distance: CGFloat) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // 閾値未満なら停止
        if distance > 100 {
            if isContinuousPlaying {
                stopContinuousHaptic()
            }
            return
        }
        
        // すでに再生中なら何もしない
        if isContinuousPlaying {
            return
        }
        
        let duration = 30.0
        
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            continuousPlayer = try engine?.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
            isContinuousPlaying = true
        } catch {
            print("再生エラー: \(error)")
        }
    }

    func stopContinuousHaptic() {
        do {
            try continuousPlayer?.stop(atTime: 0)
            continuousPlayer = nil
            isContinuousPlaying = false
        } catch {
            print("停止エラー: \(error)")
        }
    }
    
    
    func playPattern(events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("再生エラー: \(error)")
        }
    }
}
