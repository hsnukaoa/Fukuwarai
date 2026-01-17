//
//  CameraViewControllerRepresentable.swift
//  Fukuwarai
//
//  Created by 宇田川航太 on 2026/01/17.
//


import SwiftUI
import UIKit

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var faceParts: [FaceParts]

    func makeUIViewController(context: Context) -> CameraViewController {
        let camera = CameraViewController()
        camera.onPhotoCaptured = { image in
            capturedImage = image
        }
        camera.onFacePartsDetected = { parts in
            faceParts = parts
        }
        return camera
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}