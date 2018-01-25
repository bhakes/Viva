//
//  ARViewController+HUD.swift
//  Viva-Example
//
//  Created by Txai Wieser on 13/01/18.
//

import UIKit
import ARKit

extension ARViewController {
    func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
        textManager.blurBackground()
        
        if allowRestart {
//            let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
//                self.textManager.unblurBackground()
//                self.restartExperience(self)
//            }
            textManager.showAlert(title: title, message: message, actions: [])//[restartAction])
        } else {
            textManager.showAlert(title: title, message: message, actions: [])
        }
    }
}
