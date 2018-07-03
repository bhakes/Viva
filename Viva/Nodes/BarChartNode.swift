//
//  BarChartNode.swift
//  Viva
//
//  Created by Txai Wieser on 29/10/17.
//

import Foundation
import SceneKit

public class BarChartNode: BaseChartNode {
    public var data: BarChartData!
    
    public override init() {
        super.init(thumbImageFilename: "bar", title: "Gráfico de Barras")
        self.chartLength = 20
        self.chartWidth = 200
        self.chartHeight = 160
    }
    
    public override func loadModel() {
        super.loadModel()
        
//        func decodeLocalJSONFile<T: Codable>(withName name: String) -> T {
//            let path = Bundle.main.url(forResource: name, withExtension: "json")!
//            let data = try! Data(contentsOf: path)
//            return try! JSONDecoder().decode(T.self, from: data)
//        }
//        
//        let values: [String: [Double]] = decodeLocalJSONFile(withName: "testValues")
//
//        let sets: [BarChartDataSet] = values.map { setDic in
//            let values = setDic.value.enumerated().map { return BarChartDataEntry(x: $0.offset, y: Int($0.element*100000)) }
//            let entry = BarChartDataSet(values: values, label: "Entry \(setDic.key)")
//            return entry
//        }
        if data == nil {
            let sets: [BarChartDataSet] = (1...8).map { entryNumber in
                let values = (0...11).map { return BarChartDataEntry(x: $0, y: Int.random(min: 20, max: 80)) }
                let entry = BarChartDataSet(values: values, label: "Entry \(entryNumber)", color: .random())
                return entry
            }
            data = BarChartData(dataSets: sets, label: "Testing")
        }
        reloadChart()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let gapBetweenSets: Double = 1 // In percentage of the calculated lineWidth
    let gapBetweenBars: Double = 1 // In percentage of the calculated lineWidth
    
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

        let barWidth: CGFloat = CGFloat(calculateSetBarWidth())
        let barLength: CGFloat = CGFloat(calculateSetDepth())
        
        for (setIndex, pureSet) in data.dataSets.enumerated() {
            let setValuesPoints = pureSet.values.map { return CGPoint(x: Double($0.x - minWidthValue) * xMultiplier,
                                                                      y: Double($0.y - minHeightValue) * yMultiplier) }
            let setNode = SCNNode()
            setNode.name = nameForSet(withIndex: setIndex)
            
            for (valueIndex, value) in setValuesPoints.enumerated() {
                let barHeight: CGFloat = abs(value.y)
                let shape = SCNBox(width: barWidth, height: barHeight, length: barLength, chamferRadius: 0)
                
                let material = SCNMaterial()
                material.diffuse.contents = data.dataSets[setIndex % data.dataSets.count].color
                material.normal.contents = UIImage(named: "noise2")
                material.normal.intensity = 0.4
                shape.materials = [material]
                
                let node = SCNNode(geometry: shape)
                node.name = nameForBar(fromSet: setIndex, andValueIndex: valueIndex)
                node.position.x = Float(value.x)
                node.position.y = Float(value.y/2)
                setNode.addChildNode(node)
                node.categoryBitMask = CategoryBitmask.subNodes.rawValue
            }
            
            setNode.position = calculateSetPos(setIndex: setIndex)
            addChildNode(setNode)
        }
        self.categoryBitMask = CategoryBitmask.nodes.rawValue
    }
    
    func nameForSet(withIndex setIndex: Int) -> String {
        return "barChartNode_set_\(setIndex)"
    }
    
    func nameForBar(fromSet setIndex: Int, andValueIndex valueIndex: Int) -> String {
        return "barChartNode_bar_\(setIndex)_\(valueIndex)"
    }
    
    func indexes(forNodeName nodeName: String?) -> (Int, Int)? {
        guard var components = nodeName?.components(separatedBy: "_"),
            let valueIndexString = components.popLast(),
            let setIndexString = components.popLast(),
            let valueIndex = Int(valueIndexString),
            let setIndex = Int(setIndexString) else { return nil }
        
        return (setIndex, valueIndex)
    }
    
    var highlightedNode: SCNNode?
    var textNode: SCNNode?
    
    public override func highlightText(node: SCNNode) -> String? {
        if let indexes = self.indexes(forNodeName: node.name) {
            let value = data.dataSets[indexes.0].values[indexes.1]
            let text = "Coluna: \(value.x)\nValor: \(value.y)"
            return text
        } else {
            return nil
        }
    }
    
    public override func highlight(node: SCNNode) {
        if let lastHighlightedNode = highlightedNode, let indexes = self.indexes(forNodeName: lastHighlightedNode.name) {
            lastHighlightedNode.geometry?.firstMaterial?.diffuse.contents = data.dataSets[indexes.0 % data.dataSets.count].color
        }
        
//        if let lasTextNode = textNode {
//            lasTextNode.removeFromParentNode()
//            textNode = nil
//        }
        
        if let indexes = self.indexes(forNodeName: node.name) {
            let value = data.dataSets[indexes.0].values[indexes.1].y
//            let text = SCNText(string: String(value), extrusionDepth: 2)
//            text.firstMaterial?.diffuse.contents = UIColor.white
//            
//            let n = SCNNode(geometry: text)
//            n.position.y = Float(chartHeight) * 1.2
//            addChildNode(n)
//            textNode = n
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            highlightedNode = node
        } else {
            highlightedNode = nil
        }
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
    
    func calculateGapBetweenBars() -> Double {
        return gapBetweenBars * calculateSetBarWidth()
    }
    
    func calculateSetBarWidth() -> Double {
        let maxBarCount = Double(data.dataSets.reduce(0) { return max($0, $1.values.count) })
        let additionalSpace: Double = 0
        // chartWidth = additional + (maxBarCount * barWidth) + ((maxBarCount - 1) * (gapBetweenBars * barWidth))
        return (chartWidth - additionalSpace) / (gapBetweenBars * (maxBarCount - 1) + maxBarCount)
    }
    
    func calculateSetPos(setIndex: Int) -> SCNVector3 {
        let xPos: Double = -chartWidth/2
        let yPos: Double = 0
        let zPos: Double = Double(setIndex) * (calculateGapBetweenSets() + calculateSetDepth()) - (chartLength / 2)
        return SCNVector3(xPos, yPos, zPos)
    }
}
