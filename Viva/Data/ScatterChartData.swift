//
//  ScatterChartData.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct ScatterChartData {
    var dataSets: [ScatterChartDataSet]
    var label: String?
    
    public init(dataSets: [ScatterChartDataSet], label: String?) {
        self.dataSets = dataSets
        self.label = label
    }
}
