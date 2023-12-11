//
//  ChartView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/13.
//

import SwiftUI

struct SubmissionChartCell: ViewModifier {
    let corner: CGFloat
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .stroke(Color.clear, lineWidth: 2.0)
            )
            .cornerRadius(corner)
    }
}
