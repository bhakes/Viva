//
//  ARViewController+VirtualObjectSelectionViewControllerDelegate.swift
//  Viva-Example
//
//  Created by Txai Wieser on 13/01/18.
//

import UIKit
import ARKit

extension ARViewController: VirtualObjectSelectionViewControllerDelegate {
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController?, object: VirtualObject) {
        loadVirtualObject(object: object)
    }
    
    func loadVirtualObject(object: VirtualObject) {
        // Show progress indicator
//        let spinner = UIActivityIndicatorView()
//        spinner.center = addObjectButton.center
//        spinner.bounds.size = CGSize(width: addObjectButton.bounds.width - 5, height: addObjectButton.bounds.height - 5)
//        sceneView.addSubview(spinner)
//        spinner.startAnimating()
        
        DispatchQueue.global().async {
            self.isLoadingObject = true
            object.viewController = self
            VirtualObjectsManager.shared.addVirtualObject(virtualObject: object)
            VirtualObjectsManager.shared.setVirtualObjectSelected(virtualObject: object)
            
            object.loadModel()
            
            DispatchQueue.main.async {
                if let lastFocusSquarePos = self.focusSquare?.lastPosition {
                    self.setNewVirtualObjectPosition(lastFocusSquarePos)
                } else {
                    self.setNewVirtualObjectPosition(SCNVector3Zero)
                }
                
//                spinner.removeFromSuperview()
                
                // Update the icon of the add object button
//                let buttonImage = UIImage.composeButtonImage(from: object.thumbImage)
//                let pressedButtonImage = UIImage.composeButtonImage(from: object.thumbImage, alpha: 0.3)
//                self.addObjectButton.setImage(buttonImage, for: [])
//                self.addObjectButton.setImage(pressedButtonImage, for: [.highlighted])
                self.isLoadingObject = false
            }
        }
    }
}

