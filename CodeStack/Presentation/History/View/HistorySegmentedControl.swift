//
//  HistorySegmentedControl.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit


enum SegType: String,CaseIterable{
    case favorite = "즐겨찾기"
    case tempSave = "임시저장"
    case success = "성공"
    case failure = "실패"
    case all = "전체"
    
    enum Value: Int{
        case favorite = 0
        case tempSave = 1
        case success = 2
        case failure = 3
        case all = 4
    }
    
    static func switchSegType(value: Value) -> SolveStatus{
        switch value{
        case .favorite:
            return .favorite
        case .tempSave:
            return .temp
        case .success:
            return .solve
        case .failure:
            return .fail
        default:
            return .none
        }
    }
}

class HistorySegmentedControl: UISegmentedControl{
    
    private let font = UIFont.boldSystemFont(ofSize: 14)
    
    private var segWidths: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        UISegmentedControl.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        removeBackgroundAndDivider()
        
        SegType.allCases
            .enumerated().forEach
        { index, value in
            self.insertSegment(withTitle: value.rawValue, at: index, animated: true)
            segWidths.append(titleForSegment(at: index)?.width(withConstrainedHeight: 0, font: font) ?? 0)
            self.setWidth(segWidths[index] + 20, forSegmentAt: index)
        }
    }
    
    override func draw(_ rect: CGRect){
        let x = calculateWidth(for: selectedSegmentIndex)
        let yHeight = self.bounds.size.height - 1.0
        
        segmentSelecteLayer(x: x, y: yHeight)
        
        let separtorPointOne = calculateWidth(for: 4)
        let separtorPointTwo = calculateWidth(for: 1)
        addSeparatorLine(x: separtorPointOne, y: rect.origin.y, height: yHeight)
        addSeparatorLine(x: separtorPointTwo, y: rect.origin.y, height: yHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    private func segmentSelecteLayer(x: CGFloat,y: CGFloat){
        // 첫번째 인덱스에서는 빈 배열로 값이 반환되기때문에 spacing 10을 더해준다.
        let xPosition = x + 10
        let yPosition = y
        
        /// String width with font
        let selectedSegWidth = segWidths[safe: selectedSegmentIndex] ?? 10
        
        let layer = UIBezierPath()
        
        layer.lineWidth = 2.0
        layer.move(to: CGPoint(x: xPosition, y: yPosition))
        layer.addLine(to: CGPoint(x: xPosition + selectedSegWidth , y: yPosition))
        UIColor.sky_blue.setStroke()
        layer.stroke()
    }
    
    
    private func addSeparatorLine(x: CGFloat, y: CGFloat, height : CGFloat) {
        let x = x
        let y = y
        
        let separatorHeight = "Temp".height(withConstrainedWidth: .infinity, font: font)
        let spacing = (height - separatorHeight) / 2
        
        let separatorPath = UIBezierPath()
        separatorPath.lineWidth = 2.0
        separatorPath.move(to: CGPoint(x: x,
                                       y: y + spacing))
        
        separatorPath.addLine(to: CGPoint(x: x,
                                          y: height - spacing))
        
        UIColor.lightGray.setStroke()
        separatorPath.stroke()
    }
    
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func calculateWidth(for index: Int) -> CGFloat{
        return Array(segWidths[safe: 0..<index] ?? [])
            .compactMap{$0 + 20}
            .reduce(0, +)
    }
}
