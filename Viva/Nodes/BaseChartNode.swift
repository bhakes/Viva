//
//  BaseChartNode.swift
//  Viva
//
//  Created by Txai Wieser on 28/10/17.
//

import Foundation
import SceneKit

public class BaseChartNode: VirtualObject {
    public var chartHeight: Double = 100
    public var chartWidth: Double = 100
    public var chartLength: Double = 100
    
    public func highlight(node: SCNNode) {}
    public func highlightText(node: SCNNode) -> String? { return nil }
    
    public func reloadChart() {}
    
    private func reloadContainer() {
        if let box = geometry as? SCNBox {
            let inset: CGFloat = 8
            box.width = CGFloat(chartWidth) + 2*inset
            box.height = CGFloat(chartHeight) + 2*inset
            box.length = CGFloat(chartLength) + 2*inset
        }
    }
    
    
    public override func loadModel() {
//        let container = SCNBox()
//        container.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.4)
//        //        container.firstMaterial?.diffuse.contents = UIColor.clear
//        geometry = container
//        reloadContainer()
        scale = SCNVector3(0.006, 0.006, 0.006)
    }
}

public enum AvailableChart {
    case pie
    case line
    case bar
    case scatter
    public static let allCases: [AvailableChart] = [.pie, .line, .bar, .scatter]
    
    public func name() -> String {
        switch self {
        case .pie:
            return "Pie Chart"
        case .line:
            return "Line Chart"
        case .bar:
            return "Bar Chart"
        case .scatter:
            return "Scatter Chart"
        }
    }

    public func create() -> BaseChartNode {
        switch self {
        case .pie:
            return PieChartNode()
        case .line:
            return LineChartNode()
        case .bar:
            return BarChartNode()
        case .scatter:
            return ScatterChartNode()
        }
    }
}
