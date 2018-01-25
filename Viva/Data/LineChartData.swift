//
//  LineChartData.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct LineChartData {
    var dataSets: [LineChartDataSet]
    var label: String?
    
    public init(dataSets: [LineChartDataSet], label: String?) {
        self.dataSets = dataSets
        self.label = label
    }
}
