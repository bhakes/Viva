//
//  SCNViewController.swift
//  Viva-Example
//
//  Created by Txai Wieser on 18/10/17.
//

import UIKit
import SceneKit
import Viva

final class SCNViewController: UIViewController, ScrollChooserViewDelegate {
    private let charts: [BaseChartNode] = AvailableChart.allCases.map { $0.create() }
    
    @IBOutlet
    private weak var sceneView: SCNView! {
        didSet {
            sceneView.autoenablesDefaultLighting = true
            sceneView.allowsCameraControl = true
            sceneView.showsStatistics = true
            sceneView.backgroundColor = .black
//            sceneView.debugOptions = [.showCameras, .showWireframe]
            sceneView.scene = SCNScene()
            sceneView.scene!.rootNode.addChildNode(cameraNode)
        }
    }
    
    private let cameraNode: SCNNode = {
        let n = SCNNode()
        n.camera = SCNCamera()
        n.camera!.automaticallyAdjustsZRange = true
        n.position.z = 300
        return n
    }()
    
    @IBOutlet
    private weak var scrollChooserView: ScrollChooserView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureChooser()
    }
    
    private func configureChooser() {
        scrollChooserView.choserDelegate = self
        
        charts.forEach {
            let b = UIButton()
            b.setTitle($0.title, for: .normal)
            b.backgroundColor = .random()
            b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            scrollChooserView.addButton(b)
        }
        scrollChooser(scrollChooserView, didSelectButtonWithID: 0)
    }
    
    func scrollChooser(_ scrollChoser: ScrollChooserView, didSelectButtonWithID id: Int) {
        guard let rootNode = sceneView.scene?.rootNode else { return }
        rootNode.childNodes.forEach { $0.removeFromParentNode() }
        rootNode.addChildNode(cameraNode)
        
        let selectedChart = charts[id]
        selectedChart.loadModel()
        selectedChart.scale = SCNVector3(0.5, 0.5, 0.5)
        rootNode.addChildNode(selectedChart)
    }
    
    @IBAction
    private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
}
