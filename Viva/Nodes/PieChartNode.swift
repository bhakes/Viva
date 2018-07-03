//
//  PieChartNode.swift
//  Viva
//
//  Created by Txai Wieser on 15/10/17.
//

import Foundation
import SceneKit

public class PieChartNode: BaseChartNode {
    public var data: PieChartData!
    
    let startAngle: Double = 3/2 * .pi
    var valuesColors: [UIColor] = [.random()]

    public override init() {
        super.init(thumbImageFilename: "pie", title: "Gráfico de Pizza")
        self.chartHeight = 60
        self.chartWidth = 100
        self.chartLength = 100
    }
    
    public override func loadModel() {
        super.loadModel()

        if data == nil {
            var entries: [PieChartDataEntry] = []
            var total: Int = 0
            while total < 100 {
                var value = Int.random(min: 1, max: 50)
                if (total + value) > 100 {
                    value = 100 - total
                }
                total += value
                let entry = PieChartDataEntry(value: Double(value))
                entries.append(entry)
            }
            
            valuesColors = entries.map { _ in .random() }
            let set = PieChartDataSet(values: entries, label: "Entry 1")
            data = PieChartData(dataSet: set, label: "Testing")
        }
        reloadChart()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nameForSet(withIndex setIndex: Int) -> String {
        return "pieChartNode_set_\(setIndex)"
    }
    
    func nameForValue(fromSet setIndex: Int, andValueIndex valueIndex: Int) -> String {
        return "pieChartNode_bar_\(setIndex)_\(valueIndex)"
    }
    
    func indexes(forNodeName nodeName: String?) -> (Int, Int)? {
        guard var components = nodeName?.components(separatedBy: "_"),
            let valueIndexString = components.popLast(),
            let setIndexString = components.popLast(),
            let valueIndex = Int(valueIndexString),
            let setIndex = Int(setIndexString) else { return nil }
        
        return (setIndex, valueIndex)
    }
    
    public override func highlightText(node: SCNNode) -> String? {
        if let indexes = self.indexes(forNodeName: node.name) {
            let value = data.dataSet.values[indexes.1]
            let text = "y: \(value.value)"
            return text
        } else {
            return nil
        }
    }
    
    var highlightedNode: SCNNode?
    public override func highlight(node: SCNNode) {
        if let lastHighlightedNode = highlightedNode, let indexes = self.indexes(forNodeName: lastHighlightedNode.name) {
            lastHighlightedNode.geometry?.firstMaterial?.diffuse.contents = valuesColors[indexes.1 % valuesColors.count]
        }
        
        highlightedNode = node
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
    }
    
    public override func reloadChart() {
        super.reloadChart()
        childNodes.forEach { $0.removeFromParentNode() }

        let set = data.dataSet
        let radius: CGFloat = CGFloat(min(chartWidth, chartLength)/2)
        let center: CGPoint = .zero
        
        let setNode = SCNNode()
        var cumulativeStartAngle = CGFloat(startAngle)
        let values = set.values
        for (index, value) in values.enumerated() {
            let endAngle: CGFloat = (2 * .pi) * (CGFloat(value.value) / 100)
            let finalAngle = cumulativeStartAngle + endAngle
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: cumulativeStartAngle, endAngle: cumulativeStartAngle + endAngle, clockwise: true)
            path.close()
            
            cumulativeStartAngle = finalAngle
            
            let shape = SCNShape(path: path, extrusionDepth: CGFloat(chartHeight))
            let node = SCNNode(geometry: shape)
            node.name = nameForValue(fromSet: 0, andValueIndex: index)
            
            let material = SCNMaterial()
            material.diffuse.contents = valuesColors[index % valuesColors.count]
            material.normal.contents = UIImage(named: "noise2")
            material.normal.intensity = 0.4
            shape.materials = [material]
            
            node.position.z = -Float(chartHeight)/2
            setNode.addChildNode(node)
            
        }
        setNode.eulerAngles.x = .pi/2
        addChildNode(setNode)
    }
}
