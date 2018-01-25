//
//  BarChartData.swift
//  Viva
//
//  Created by Txai Wieser on 29/10/17.
//

import Foundation

public struct BarChartData {
    var dataSets: [BarChartDataSet]
    var label: String?
    
    public init(dataSets: [BarChartDataSet], label: String?) {
        self.dataSets = dataSets
        self.label = label
    }
}
