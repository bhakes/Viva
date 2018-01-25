//
//  PieChartDataSet.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct PieChartDataSet {
    var values: [PieChartDataEntry]
    var label: String?
    
    public init(values: [PieChartDataEntry], label: String?) {
        self.values = values
        self.label = label
    }
}
