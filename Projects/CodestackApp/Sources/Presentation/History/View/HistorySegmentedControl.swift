//
//  HistorySegmentedControl.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/18.
//

import UIKit
import Global

class HistorySegmentedControl: UISegmentedControl {
    
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
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        let x = calculateWidth(for: selectedSegmentIndex)
        let yHeight = layer.bounds.size.height - 1.0
        self.layer.delegate = self

        segmentSelecteLayer(x: x, y: yHeight, ctx: ctx)
        let separtorPointOne = calculateWidth(for: 2)
        let separtorPointTwo = calculateWidth(for: 1)
        addSeparatorLine(x: separtorPointOne, y: layer.bounds.origin.y, height: yHeight, ctx: ctx)
        addSeparatorLine(x: separtorPointTwo, y: layer.bounds.origin.y, height: yHeight, ctx: ctx)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    private func segmentSelecteLayer(x: CGFloat,y: CGFloat, ctx: CGContext) {
        // 첫번째 인덱스에서는 빈 배열로 값이 반환되기때문에 spacing 10을 더해준다.
        let xPosition = x + 10
        let yPosition = y
        
        /// String width with font
        let selectedSegWidth = segWidths[safe: selectedSegmentIndex] ?? 10
        
        ctx.setLineWidth(5)
        ctx.move(to: CGPoint(x: xPosition, y: yPosition))
        ctx.addLine(to: CGPoint(x: xPosition + selectedSegWidth, y: yPosition))
        ctx.setStrokeColor(UIColor.sky_blue.cgColor)
        ctx.strokePath()
    }
    
    private func addSeparatorLine(x: CGFloat, y: CGFloat, height : CGFloat, ctx: CGContext) {
        let x = x
        let y = y
        
        let separatorHeight = "Temp".height(withConstrainedWidth: .infinity, font: font)
        let spacing = (height - separatorHeight) / 2
        
        ctx.setLineWidth(2)
        ctx.move(to: CGPoint.init(x: x, y: y + spacing))
        ctx.addLine(to: CGPoint.init(x: x, y: height - spacing))
        ctx.setStrokeColor(UIColor.lightGray.cgColor)
        ctx.strokePath()
    }
    
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    private func calculateWidth(for index: Int) -> CGFloat{
        return Array(segWidths[safe: 0..<index] ?? [])
            .compactMap{$0 + 20}
            .reduce(0, +)
    }
}
