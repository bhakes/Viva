//
//  PieChartData.swift
//  Viva
//
//  Created by Txai Wieser on 20/10/17.
//

import Foundation

public struct PieChartData {
    var dataSet: PieChartDataSet
    var label: String?
    
    public init(dataSet: PieChartDataSet, label: String?) {
        self.dataSet = dataSet
        self.label = label
    }
}
