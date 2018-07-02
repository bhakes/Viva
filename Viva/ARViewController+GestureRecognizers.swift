//
//  ARViewController+GestureRecognizers.swift
//  Viva-Example
//
//  Created by Txai Wieser on 13/01/18.
//

import UIKit
import ARKit

extension ARViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let object = VirtualObjectsManager.shared.getVirtualObjectSelected() else {
            return
        }
        
        if currentGesture == nil {
            currentGesture = Gesture.startGestureFromTouches(touches, self.sceneView, object)
        } else {
            currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
        }
        
        displayVirtualObjectTransform()
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
        displayVirtualObjectTransform()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
//            chooseObject(button: addObjectButton)
            return
        }
        
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !VirtualObjectsManager.shared.isAVirtualObjectPlaced() {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
    }
}
