//
//  BarChartDataSet.swift
//  Viva
//
//  Created by Txai Wieser on 29/10/17.
//

import Foundation

public struct BarChartDataSet {
    var values: [BarChartDataEntry]
    var label: String?
    var color: UIColor
    public init(values: [BarChartDataEntry], label: String?, color: UIColor) {
        self.values = values
        self.label = label
        self.color = color
    }
}
