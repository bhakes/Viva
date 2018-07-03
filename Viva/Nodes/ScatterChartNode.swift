//
//  ScatterChartNode.swift
//  Viva
//
//  Created by Txai Wieser on 15/11/17.
//

import Foundation
import SceneKit

public class ScatterChartNode: BaseChartNode {
    public var data: ScatterChartData!
    
    public override init() {
        super.init(thumbImageFilename: "scatter", title: "Gráfico de Disperção")
    }
    
    public override func loadModel() {
        super.loadModel()
        
        if data == nil {
            let sets: [ScatterChartDataSet] = (1...8).map { entryNumber in
                let values = (0..<20).map { _ in ScatterChartDataEntry(x: .random(0...100), y: .random(0...100), z: .random(0...100)) }
                let entry = ScatterChartDataSet(values: values, label: "Entry \(entryNumber)")
                return entry
            }
            
            data = ScatterChartData(dataSets: sets, label: "Testing")
        }
        reloadChart()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let sphereRadiusHeightPercentage: Double = 0.02
    
    public override func reloadChart() {
        super.reloadChart()
        childNodes.forEach { $0.removeFromParentNode() }

        let maxWidthValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.x
            }
            return max(v, $1.x)
        }
        
        let minWidthValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.x
            }
            return min(v, $1.x)
        }
        
        let maxHeightValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.y
            }
            return max(v, $1.y)
        }
        
        let minHeightValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.y
            }
            return min(v, $1.y)
        }
        
        let maxDepthValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.z
            }
            return max(v, $1.z)
        }
        
        let minDepthValue: Int? = data.dataSets.flatMap { $0.values }.reduce(nil) {
            guard let v = $0 else {
                return $1.z
            }
            return min(v, $1.z)
        }
        
        let xMultiplier = chartWidth / Double((maxWidthValue ?? 0) - (minWidthValue ?? 0))
        let yMultiplier = chartHeight / Double((maxHeightValue ?? 0) - (minHeightValue ?? 0))
        let zMultiplier = chartLength / Double((maxDepthValue ?? 0) - (minDepthValue ?? 0))

        for (setIndex, pureSet) in data.dataSets.enumerated() {
            let setValuesPoints = pureSet.values.map {
                return SCNVector3(Double($0.x) * xMultiplier,
                                  Double($0.y) * yMultiplier,
                                  Double($0.z) * zMultiplier)
            }
            guard let _ = setValuesPoints.first else { continue }
            
            let points: [SCNNode] = setValuesPoints.map {
                let shape = SCNSphere(radius: CGFloat(chartHeight * sphereRadiusHeightPercentage))
                let point = SCNNode(geometry: shape)
                point.position = $0
                
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.random()
                material.normal.contents = UIImage(named: "noise2")
                material.normal.intensity = 0.4
                shape.materials = [material]
                
                return point
            }
            
            let node = SCNNode()
            points.forEach { node.addChildNode($0) }
            node.position = SCNVector3(-chartWidth/2, 0, -chartLength/2)
            addChildNode(node)
        }
    }
}
