//
//  Calendar.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/13.
//

import SwiftUI
import RxSwift
import RxCocoa
import RxFlow
import CommonUI


// TODO: 시스템 설정 다크/라이트 모드 분기처리 Setting 해줘야함 , 다크 모드일때 opacity reverse 해야함
struct CellColor {
    static let cellColor: Color = CColor.sky_blue.sColor
    
    static var opacityList: [Double] {
        let 다크모드: Bool = true
        let list = [0 , 0.4, 0.6, 0.8, 1.0]
        if 다크모드 {
            return list
        } else {
            // return list.reversed()
        }
    }
}

struct SubmissionChartView: View {
    @ObservedObject private var viewModel: ContributionViewModel
    
    private let cornerRadius: CGFloat = 2.0
    
    private let days: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    private let rows: Int = 7
    private let spacing: CGFloat = 5
    
    private var calendarDate: [String] {
        Date.getDateFromCurrentMonth(count: 5)
    }
    
    init(viewModel: ContributionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack{
                SubmissionChart(columns: 15, spacing: spacing) { row, column in
                    if let color = 
                        viewModel.setCellColor(columnsCount: 15)
                        .element(at: row)?
                        .element(at: column) 
                    {
                        color.modifier(SubmissionChartCell(corner: cornerRadius))
                    } else {
                        CellColor.cellColor.opacity(0)
                            .cornerRadius(cornerRadius)
                    }
                }
                .frame(width: Position.screenWidth - 80, height: 130)
            }
            
            HStack {
                Text("Less")
                    .font(.caption)
                ForEach([0.1, 0.4, 0.6 ,0.8, 1.0], id: \.self) { value in
                    CellColor.cellColor
                        .opacity(value)
                        .frame(width: 20, height: 5, alignment: .center)
                        .padding(.horizontal, -3)
                }
                Text("More")
                    .font(.caption)
            }
            .padding(.top, 8)
        }
        .padding([.leading, .trailing], 10)
    }
}
