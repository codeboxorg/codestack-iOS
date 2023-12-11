//
//  CalendarChart.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/13.
//

import SwiftUI

struct SubmissionChart<Index: View>: View {
    let rows: Int = 7    //일주일 7일
    let columns: Int
    let spacing: CGFloat
    let index: (Int, Int) -> Index
    var days: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<columns, id: \.self) { row in
                VStack(alignment: .center, spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { column in
                        index(row, column)
                    }
                }
            }
        }
    }
    
    init(columns: Int, spacing: CGFloat, @ViewBuilder index: @escaping (Int, Int) -> Index) {
        self.columns = columns
        self.spacing = spacing
        self.index = index
    }
}
