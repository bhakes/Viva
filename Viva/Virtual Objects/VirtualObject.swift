import Foundation
import SceneKit
import ARKit

public class VirtualObject: SCNNode {
	static let ROOT_NAME = "Virtual object root node"
//    var thumbImage: UIImage
    var thumbImageName: String = ""
	public var title: String = ""
	var modelLoaded: Bool = false
	var id: Int!

	var viewController: ARViewController?

	override init() {
		super.init()
		self.name = VirtualObject.ROOT_NAME
	}

	init(thumbImageFilename: String, title: String) {
        self.thumbImageName = thumbImageFilename
        super.init()
		self.id = VirtualObjectsManager.shared.generateUid()
		self.name = VirtualObject.ROOT_NAME
//        self.thumbImage = UIImage(named: thumbImageFilename, in: Bundle(for: VirtualObject.self), compatibleWith: nil)
		self.title = title
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func loadModel() {
        modelLoaded = true
	}

	public func unloadModel() {
		for child in self.childNodes {
			child.removeFromParentNode()
		}

		modelLoaded = false
	}

	func translateBasedOnScreenPos(_ pos: CGPoint, instantly: Bool, infinitePlane: Bool) {
		guard let controller = viewController else {
			return
		}
		let result = controller.worldPositionFromScreenPosition(pos, objectPos: self.position, infinitePlane: infinitePlane)
		controller.moveVirtualObjectToPosition(result.position, instantly, !result.hitAPlane)
	}
}

extension VirtualObject {

	static func isNodePartOfVirtualObject(_ node: SCNNode) -> Bool {
		if node.name == VirtualObject.ROOT_NAME {
			return true
		}

		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}

		return false
	}
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
	func reactToScale()
}

extension SCNNode {

	func reactsToScale() -> ReactsToScale? {
		if let canReact = self as? ReactsToScale {
			return canReact
		}

		if parent != nil {
			return parent!.reactsToScale()
		}

		return nil
	}
}
