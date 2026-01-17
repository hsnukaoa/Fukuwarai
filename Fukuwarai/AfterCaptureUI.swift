//
//  AfterCaptureUI.swift
//  Fukuwarai
//
//  Created by 宇田川航太 on 2026/01/17.
//

import SwiftUI

struct AfterCaptureUI: View {
    let faceParts: [FaceParts]
    @State private var partsLoaction: [CGPoint] = [CGPoint.zero, CGPoint.zero, CGPoint.zero, CGPoint.zero]
    var targetPoint: [CGPoint] = [CGPoint(x: 150, y: 240), CGPoint(x: 250, y: 240), CGPoint(x: 200, y: 320), CGPoint(x: 200, y: 380)]
    @State var distance: CGFloat = 0
    @StateObject private var haptics = HapticsManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("okame")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // ターゲットポイント（赤い丸）
                ForEach(targetPoint.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.red)
                        .frame(width: 16, height: 16)
                        .position(x: targetPoint[index].x, y: targetPoint[index].y)
                }

                // 顔パーツ（ドラッグ可能）
                if !faceParts.isEmpty {
                    ForEach(faceParts.first?.items.indices ?? 0..<0, id: \.self) { index in
                        PartView(
                            image: faceParts.first?.items[index].image,
                            title: "test",
                            size: .constant(index < 2 ? 30 : 60)
                        )
                        .position(x: partsLoaction[index].x, y: partsLoaction[index].y)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    partsLoaction[index] = value.location

                                    let dx = value.location.x - targetPoint[index].x
                                    let dy = value.location.y - targetPoint[index].y
                                    let distance = sqrt(dx * dx + dy * dy)

                                    print("📏 distance:", distance)
                                    haptics.playPositionFeedback(distance: distance)
                                }
                                .onEnded { _ in
                                    haptics.playSuccessFeedback()
                                    haptics.stopContinuousHaptic()
                                }
                        )
                    }
                }
            }
            .onAppear {
                haptics.prepareHaptics()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    haptics.prepareHaptics()
                }
            }
        }
    }
}
