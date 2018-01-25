//
//  ARViewController+Planes.swift
//  Viva-Example
//
//  Created by Txai Wieser on 13/01/18.
//

import UIKit
import ARKit

extension ARViewController {
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let pos = SCNVector3.positionFromTransform(anchor.transform)
        textManager.showDebugMessage("NEW SURFACE DETECTED AT \(pos.friendlyString())")
        
        let plane = Plane(anchor, showDebugVisuals)
        
        planes[anchor] = plane
        node.addChildNode(plane)
        
        textManager.cancelScheduledMessage(forType: .planeEstimation)
        textManager.showMessage("SURFACE DETECTED")
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
        }
    }
    
    func restartPlaneDetection() {
        // configure session
        let worldSessionConfig = (sceneView.session.configuration as? ARWorldTrackingConfiguration) ?? ARWorldTrackingConfiguration()
        worldSessionConfig.planeDetection = .horizontal
        sceneView.session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])

        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
    }

}
