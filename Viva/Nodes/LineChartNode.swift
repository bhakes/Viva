//
//  LineChartNode.swift
//  Viva
//
//  Created by Txai Wieser on 18/10/17.
//

import Foundation
import SceneKit

public class LineChartNode: BaseChartNode {
    public var data: LineChartData!
    
    public override init() {
        super.init(thumbImageFilename: "line", title: "Gráfico de Linha")
        self.chartLength = 80
        self.chartWidth = 200
        self.chartHeight = 160
    }
    
    public override func loadModel() {
        super.loadModel()
        
        if data == nil {
            let sets: [LineChartDataSet] = (1...4).map { entryNumber in
                let values = (0...7).map { return LineChartDataEntry(x: $0, y: Int.random(min: 0, max: 100)) }
                let entry = LineChartDataSet(values: values, label: "Entry \(entryNumber)", color: .random())
                return entry
            }
            
            data = LineChartData(dataSets: sets, label: "Testing")
        }
        reloadChart()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nameForSet(withIndex setIndex: Int) -> String {
        return "lineChartNode_set_\(setIndex)"
    }
    
    func nameForValue(fromSet setIndex: Int, andValueIndex valueIndex: Int) -> String {
        return "lineChartNode_bar_\(setIndex)_\(valueIndex)"
    }
    
    func indexes(forNodeName nodeName: String?) -> (Int, Int)? {
        guard var components = nodeName?.components(separatedBy: "_"),
            let valueIndexString = components.popLast(),
            let setIndexString = components.popLast(),
            let valueIndex = Int(valueIndexString),
            let setIndex = Int(setIndexString) else { return nil }
        
        return (setIndex, valueIndex)
    }

    func indexes(forSetNodeName setNodeName: String?) -> Int? {
        guard var components = setNodeName?.components(separatedBy: "_"),
            let setIndexString = components.popLast(),
            let setIndex = Int(setIndexString) else { return nil }
        
        return setIndex
    }
    
    public override func highlightText(node: SCNNode) -> String? {
        if let indexes = self.indexes(forSetNodeName: node.name) {
            let value = data.dataSets[indexes]
            let text = "Valor: \(indexes)"
            return text
        } else {
            return nil
        }
        
    }
    var highlightedNode: SCNNode?
    public override func highlight(node: SCNNode) {
        if let lastHighlightedNode = highlightedNode, let indexes = self.indexes(forSetNodeName: lastHighlightedNode.name) {
            lastHighlightedNode.geometry?.firstMaterial?.diffuse.contents = data.dataSets[indexes % data.dataSets.count].color
        }
        
        highlightedNode = node
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
    }
    
    let gapBetweenSets: Double = 1 // In percentage of the calculated lineWidth
    let lineHeight: Double = 10

    public override func reloadChart() {
        super.reloadChart()
        childNodes.forEach { $0.removeFromParentNode() }

        let maxWidthValue: Int = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.x
            }
            return max(v, $1.x)
        } ?? 0
        
        let minWidthValue: Int = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.x
            }
            return min(v, $1.x)
        } ?? 0
        
        let maxHeightValue: Int = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.y
            }
            return max(v, $1.y)
        } ?? 0
        
        let minHeightValue: Int = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.y
            }
            return min(v, $1.y)
        } ?? 0
        
        let xMultiplier = chartWidth / Double(maxWidthValue - minWidthValue)
        let yMultiplier = chartHeight / Double(maxHeightValue - minHeightValue)
        for (setIndex, pureSet) in data.dataSets.enumerated() {
            let setValuesPoints = pureSet.values.map { return CGPoint(x: Double($0.x - minWidthValue) * xMultiplier,
                                                                      y: Double($0.y - minHeightValue) * yMultiplier) }
            guard let firstValue = setValuesPoints.first else { continue }
            
            let path = UIBezierPath()
            path.move(to: firstValue)
            let valuesAfterFirst = setValuesPoints.dropFirst()
            
            for value in valuesAfterFirst {
                let p = value + CGPoint(x: 0, y: lineHeight / 2)
                path.addLine(to: p)
            }
            
            for value in setValuesPoints.reversed() {
                let p = CGPoint(x: value.x, y: 0)
                path.addLine(to: p)
            }
            path.close()
            
            let shape = SCNShape(path: path, extrusionDepth: CGFloat(calculateSetDepth()))
            let node = SCNNode(geometry: shape)
            node.name = nameForSet(withIndex: setIndex)
            node.position = calculateSetPos(setIndex: setIndex)
            
            let material = SCNMaterial()
            material.diffuse.contents = data.dataSets[setIndex % data.dataSets.count].color
            material.normal.contents = UIImage(named: "noise2")
            material.normal.intensity = 0.4
            shape.materials = [material]
            
            addChildNode(node)
            node.categoryBitMask = CategoryBitmask.subNodes.rawValue
        }
        self.categoryBitMask = CategoryBitmask.nodes.rawValue
    }
    
    func calculateGapBetweenSets() -> Double {
        return gapBetweenSets * calculateSetDepth()
    }
    
    func calculateSetDepth() -> Double {
        let setCount = Double(data.dataSets.count)
        assert(setCount > 0)
        let additionalSpace: Double = 0
        // chartDepth = additional + (setCount * setDepth) + ((setCount - 1) * (gapBetweenSets * setDepth))
        return (chartLength - additionalSpace) / (gapBetweenSets * (setCount - 1) + setCount)
    }
    
    func calculateSetPos(setIndex: Int) -> SCNVector3 {
        let xPos: Double = -chartWidth/2
        let yPos: Double = 0
        let zPos: Double = Double(setIndex) * (calculateGapBetweenSets() + calculateSetDepth()) - (chartLength / 2)
        return SCNVector3(xPos, yPos, zPos)
    }
}

public enum CategoryBitmask: Int {
    case nodes = 1
    case subNodes = 2
}
