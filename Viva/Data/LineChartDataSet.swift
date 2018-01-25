//
//  LineChartDataSet.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct LineChartDataSet {
    var values: [LineChartDataEntry]
    var label: String?
    var color: UIColor
    
    public init(values: [LineChartDataEntry], label: String?, color: UIColor) {
        self.values = values
        self.label = label
        self.color = color
    }
}
