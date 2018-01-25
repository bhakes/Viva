//
//  ScatterChartDataSet.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct ScatterChartDataSet {
    var values: [ScatterChartDataEntry]
    var label: String?
    
    public init(values: [ScatterChartDataEntry], label: String?) {
        self.values = values
        self.label = label
    }
}
