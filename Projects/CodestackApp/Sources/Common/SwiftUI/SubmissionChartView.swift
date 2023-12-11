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


//TODO: 시스템 설정 다크/라이트 모드 분기처리 Setting 해줘야함 , 다크 모드일때 opacity reverse 해야함
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
            HStack {
                Text("제출 기록")
                    .font(.title3)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                Spacer()
            }
            
            HStack {
                ForEach(calendarDate, id: \.self) { month in
                    Text(month)
                        .bold()
                        .font(.system(size: 13))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 5)
            
            HStack{
                VStack(alignment: .center ,spacing: spacing){
                    ForEach(0..<rows, id: \.self) { colum in
                        Text("\(days[colum])")
                            .bold()
                            .font(.system(size: 12))
                            
                    }.padding(.trailing, 5)
                }
                
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
                .frame(width: UIScreen.main.bounds.width - 90, height: 130)
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
            .padding(.vertical, 20)
        }
        .padding([.leading, .trailing], 10)
    }
}
