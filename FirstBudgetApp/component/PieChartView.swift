//
//  PieChart.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/27/24.
//

import SwiftUI
import Charts

struct PieChartView: View {
    let categoryTotals: [String: Double]
    
    var body: some View {
        Chart {
            ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                SectorMark(
                    angle: .value("Total", total),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(1.0)
                )
                .foregroundStyle(by: .value("Category", category))
                .annotation(position: .overlay, alignment: .center) {
                    VStack {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(total, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .chartLegend(.visible)
    }
}
