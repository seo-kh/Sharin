//
//  CameraViewController+ARSessionDelegate.swift
//  Sharin
//
//  Created by james seo on 2023/04/04.
//

import ARKit

extension CameraViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "anchor" {
                vm.loadEntity(for: anchor, cvc: self)
            }
        }
    }
}
