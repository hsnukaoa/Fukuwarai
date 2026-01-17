//
//  SmileCheck.swift
//  Fukuwarai
//
//  Created by 宇田川航太 on 2026/01/17.
//

import ARKit

class SmileCheck: NSObject, ARSessionDelegate {
    var onSmileUpdate: ((Double) -> Void)?
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        let leftSmile = faceAnchor.blendShapes[.mouthSmileLeft]?.doubleValue ?? 0
        let rightSmile = faceAnchor.blendShapes[.mouthSmileRight]?.doubleValue ?? 0
        
        let score = (leftSmile + rightSmile) / 2.0
        onSmileUpdate?(score)
    }
}
