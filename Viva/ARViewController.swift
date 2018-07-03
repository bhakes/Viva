//
//  ARViewController.swift
//  Viva-Example
//
//  Created by Txai Wieser on 18/10/17.
//

import UIKit
import SceneKit
import ARKit

open class ARViewController: UIViewController {
    var sceneView: ARSCNView {
        return view as! ARSCNView
    }
    var textManager: TextManager!
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint?
    var currentGesture: Gesture?

    var planes = [ARPlaneAnchor: Plane]()
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances: [CGFloat] = []
    let DEFAULT_DISTANCE_CAMERA_TO_OBJECTS: Float = 10

    var dragOnInfinitePlanesEnabled = false

    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
//                self.settingsButton.isEnabled = !self.isLoadingObject
//                self.addObjectButton.isEnabled = !self.isLoadingObject
//                self.screenshotButton.isEnabled = !self.isLoadingObject
//                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    public var singleChart: BaseChartNode?
    
    open override func loadView() {
        view = ARSCNView()
        view.backgroundColor = .black
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
//        setupDebug()
        setupUIControls()
        setupFocusSquare()
//        updateSettings()
//        resetVirtualObject()
        
        showDebugVisuals = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        restartPlaneDetection()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    var addObjectButton: UIBarButtonItem!
    
    @objc
    func chooseObject(button: UIBarButtonItem) {
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        guard singleChart == nil else {
            self.virtualObjectSelectionViewController(nil, object: singleChart!)
            return
        }
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        
        let rowHeight = 45
        let popoverSize = CGSize(width: 250, height: rowHeight * VirtualObjectSelectionViewController.COUNT_OBJECTS)

        let objectViewController = VirtualObjectSelectionViewController(size: popoverSize)
        objectViewController.delegate = self
        objectViewController.modalPresentationStyle = .popover
        objectViewController.popoverPresentationController?.delegate = self
        self.present(objectViewController, animated: true, completion: nil)

        objectViewController.popoverPresentationController?.barButtonItem = button
    }
    
    
    var hitTestVisualization: HitTestVisualization?

    
    var showDebugVisuals: Bool = false {
        didSet {
            textManager.messagePanel.isHidden = !showDebugVisuals
            planes.values.forEach { $0.showDebugVisualization(showDebugVisuals) }
            sceneView.debugOptions = []
            if showDebugVisuals {
                sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
            }
        }
    }
    
    private var disableDebugButton: UIBarButtonItem!
    @IBAction func disableDebug(sender: UIBarButtonItem) {
        let vc = UIAlertController(title: "Desativar informações de posição",
                                  message: "Informações de detecção de planos não serão mais visiveis.", preferredStyle: UIAlertControllerStyle.alert)
        
        vc.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            guard let `self` = self else { return }
            self.showDebugVisuals = !self.showDebugVisuals
        }))
        vc.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
    
    private var restartExperienceButton: UIBarButtonItem!
    private var restartExperienceButtonIsEnabled: Bool = true
    @IBAction func restartExperience(sender: UIBarButtonItem!) {
        guard restartExperienceButtonIsEnabled, !isLoadingObject else {
            return
        }
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            self.sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.setupFocusSquare()
            //            self.loadVirtualObject()
            self.restartPlaneDetection()

//            self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            // Disable Restart button for five seconds in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.restartExperienceButtonIsEnabled = true
            })
        }
    }
    
    
    
    func setupUIControls() {
        textManager = TextManager(viewController: self)
        
        addObjectButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(chooseObject))
        
        restartExperienceButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartExperience))
        
        disableDebugButton = UIBarButtonItem(image: UIImage(named: "info"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(disableDebug))
        
        addObjectButton.tintColor = .white
        restartExperienceButton.tintColor = .white
        disableDebugButton.tintColor = .white
        
        UIView.appearance(whenContainedInInstancesOf: [ARViewController.self]).tintColor = nil
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [ARViewController.self]).tintColor = nil
        UIToolbar.appearance(whenContainedInInstancesOf: [ARViewController.self]).tintColor = nil
        
        let bottomBar = UIToolbar()
        bottomBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        bottomBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        bottomBar.backgroundColor = .clear
        bottomBar.tintColor = .white
        bottomBar.barStyle = .black

        
        self.view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        bottomBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        bottomBar.setItems([restartExperienceButton,
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            addObjectButton,
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            disableDebugButton], animated: false)
        
        self.view.addSubview(toolTip.0)
        toolTip.0.translatesAutoresizingMaskIntoConstraints = false
        toolTip.0.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        toolTip.0.bottomAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }
    
    func refreshFeaturePoints() {
        guard showDebugVisuals else {
            return
        }
        
        guard let cloud = sceneView.session.currentFrame?.rawFeaturePoints else {
            return
        }
        
        DispatchQueue.main.async {
            self.textManager.showFeaturePointsText("Features: \(cloud.__count)".uppercased())
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    let toolTip: (UIView, UILabel) = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        v.layer.cornerRadius = 8.0
        v.clipsToBounds = true
        
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        
        let v1 = UIView()
        v.contentView.addSubview(v1)
        v1.translatesAutoresizingMaskIntoConstraints = false
        v1.topAnchor.constraint(equalTo: v.contentView.topAnchor).isActive = true
        v1.bottomAnchor.constraint(equalTo: v.contentView.bottomAnchor).isActive = true
        v1.leftAnchor.constraint(equalTo: v.contentView.leftAnchor).isActive = true
        v1.rightAnchor.constraint(equalTo: v.contentView.rightAnchor).isActive = true
            
        let ev = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight)))
        v1.addSubview(ev)
        ev.translatesAutoresizingMaskIntoConstraints = false
        ev.topAnchor.constraint(equalTo: v1.topAnchor).isActive = true
        ev.bottomAnchor.constraint(equalTo: v1.bottomAnchor).isActive = true
        ev.leftAnchor.constraint(equalTo: v1.leftAnchor).isActive = true
        ev.rightAnchor.constraint(equalTo: v1.rightAnchor).isActive = true
            
        let v2 = UIView()
        ev.contentView.addSubview(v2)
        v2.translatesAutoresizingMaskIntoConstraints = false
        v2.topAnchor.constraint(equalTo: ev.contentView.topAnchor).isActive = true
        v2.bottomAnchor.constraint(equalTo: ev.contentView.bottomAnchor).isActive = true
        v2.leftAnchor.constraint(equalTo: ev.contentView.leftAnchor).isActive = true
        v2.rightAnchor.constraint(equalTo: ev.contentView.rightAnchor).isActive = true
        
        v2.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: v2.layoutMarginsGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: v2.layoutMarginsGuide.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: v2.layoutMarginsGuide.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: v2.layoutMarginsGuide.rightAnchor).isActive = true
        
        return (v, label)
    }()
    
    func updateTooltip() {
        toolTip.0.isHidden = true
        guard let screenCenter = screenCenter else { return }
        
//        guard let tappedRootNode: SCNNode = self.sceneView.hitTest(screenCenter, options: [.categoryBitMask: CategoryBitmask.nodes.rawValue,
//                                                                                           .backFaceCulling: false]).first?.node else { return }
//        guard let rootChartNode = tappedRootNode as? BaseChartNode else { return }
        guard let tappedNode: SCNNode = self.sceneView.hitTest(screenCenter, options: [.categoryBitMask: CategoryBitmask.subNodes.rawValue,
                                                                                       .backFaceCulling: false]).first?.node else { return }
        var rootChartNode: SCNNode = tappedNode
        
        while let n = rootChartNode.parent {
            rootChartNode = n
            if rootChartNode is BaseChartNode { break }
        }
        
        guard rootChartNode != tappedNode else { return }
        guard let rootBaseChartNode = rootChartNode as? BaseChartNode else { return }
        rootBaseChartNode.highlight(node: tappedNode)
        
        
        toolTip.1.text = rootBaseChartNode.highlightText(node: tappedNode)
        toolTip.0.isHidden = toolTip.1.text == nil
        
//        if virtualObject != nil && sceneView.isNode(virtualObject!, insideFrustumOf: sceneView.pointOfView!) {
//            focusSquare?.hide()
//        } else {
//            focusSquare?.unhide()
//        }
    }
}
//    @IBAction func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        let location = gestureRecognizer.location(in: sceneView)
//
//        guard let tappedNode: SCNNode = self.sceneView.hitTest(location, options: nil).first?.node else { return }
//        guard let chartNode = tappedNode as? BaseChartNode else { return }
//
//        if let position = sceneView.worldPosition(fromScreenPosition: location, objectPosition: nil) {
//            chartNode.position = SCNVector3(position.position.x, position.position.y, position.position.z)
//        }
//    }
//
//    @IBAction func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
//        let location = gestureRecognizer.location(in: sceneView)
//
//        guard let tappedNode: SCNNode = self.sceneView.hitTest(location, options: nil).first?.node else { return }
//        guard let chartNode = tappedNode as? BaseChartNode else { return }
//
//        let value = Double(gestureRecognizer.scale)
//        gestureRecognizer.scale = 1.0
//
//        chartNode.chartHeight *= value
//        chartNode.chartLength *= value
//        chartNode.chartWidth *= value
//        chartNode.reloadChart()
//    }
//
//    @IBAction func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
//        let location = gestureRecognizer.location(in: sceneView)
//
//        guard let tappedNode: SCNNode = self.sceneView.hitTest(location, options: nil).first?.node else { return }
//        guard let chartNode = tappedNode as? BaseChartNode else { return }
//
//        let value = Float(gestureRecognizer.rotation)
//        chartNode.eulerAngles.y = -value
//    }
//
//    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
//        let location = gestureRecognizer.location(in: sceneView)
//
//        guard let tappedRootNode: SCNNode = self.sceneView.hitTest(location, options: [.categoryBitMask: CategoryBitmask.nodes.rawValue,
//                                                                                       .backFaceCulling: false]).first?.node else { return }
//        guard let rootChartNode = tappedRootNode as? BaseChartNode else { return }
//        guard let tappedNode: SCNNode = self.sceneView.hitTest(location, options: [.rootNode: rootChartNode,
//                                                                                   .categoryBitMask: CategoryBitmask.subNodes.rawValue,
//                                                                                   .backFaceCulling: false]).first?.node else { return }
//
//        guard rootChartNode != tappedNode else { return }
//        rootChartNode.highlight(node: tappedNode)
//    }
//
//    @IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//        let location = gestureRecognizer.location(in: sceneView)
//
//        guard let tappedRootNode: SCNNode = self.sceneView.hitTest(location, options: [.categoryBitMask: CategoryBitmask.nodes.rawValue,
//                                                                                       .backFaceCulling: false]).first?.node else { return }
//        guard let rootChartNode = tappedRootNode as? BaseChartNode else { return }
//        guard let tappedNode: SCNNode = self.sceneView.hitTest(location, options: [.rootNode: rootChartNode,
//                                                                                   .categoryBitMask: CategoryBitmask.subNodes.rawValue,
//                                                                                   .backFaceCulling: false]).first?.node else { return }
//
//        guard rootChartNode != tappedNode else { return }
//        rootChartNode.highlight(node: tappedNode)
//    }
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
//    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
//
//    var screenCenter: CGPoint {
//        let bounds = sceneView.bounds
//        return CGPoint(x: bounds.midX, y: bounds.midY)
//    }
//
//    @IBAction
//    private func resetTracking() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        configuration.isLightEstimationEnabled = true
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//        sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
//    }
//
//    private var selectedChart: AvailableChart? = .line
//
//    @IBAction
//    private func selectChartType(sender: UIBarButtonItem) {
//        let options = AvailableChart.allCases
//        let alert = UIAlertController(title: "Select Chart.",
//                                      message: "Choose the type of chart to be added to the real world.",
//                                      preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self, weak sender] _ in
//            sender?.title = self?.selectedChart?.name() ?? "Select Chart"
//        }))
//        options.forEach { option in
//            let action = UIAlertAction(title: option.name(), style: .default, handler: { [weak self, weak sender] _ in
//                self?.selectedChart = option
//                sender?.title = option.name()
//            })
//            alert.addAction(action)
//        }
//        present(alert, animated: true, completion: nil)
//    }
//
//    @IBAction
//    private func addChartType(sender: UIBarButtonItem) {
//        guard let selectedChart = selectedChart else { return }
//        guard let cameraTransform = session.currentFrame?.camera.transform,
//            let focusSquarePosition = focusSquare.lastPosition else {
//                //                statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
//                return
//        }
//        let box = focusSquare.boundingBox
//        let virtualObject = selectedChart.create()
//        let scale: Double = 100
//        virtualObject.chartHeight = 2 * Double(box.max.x - box.min.x) * scale
//        virtualObject.chartWidth = 2 * Double(box.max.x - box.min.x) * scale
//        virtualObject.chartLength = 2 * Double(box.max.z - box.min.z) * scale
//        virtualObject.scale = SCNVector3(1/scale, 1/scale, 1/scale)
//        virtualObject.setPosition(focusSquarePosition, relativeTo: cameraTransform)
//        virtualObject.reloadChart()
//
//        updateQueue.async {
//            self.sceneView.scene.rootNode.addChildNode(virtualObject)
//        }
//    }

// MARK: - UIPopoverPresentationControllerDelegate
extension ARViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
