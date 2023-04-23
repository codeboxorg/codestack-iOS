//
//  NumberLinesView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import CoreImage

class LineNumberRulerView: UIView {
    private weak var textView: UITextView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func settingTextView(_ textView: UITextView){
        self.textView = textView
        self.backgroundColor = textView.backgroundColor
        self.layer.addBorder(side: .right, thickness: 1, color: UIColor.systemGray.cgColor)
        
        if !textView.text.isEmpty{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self else {return}
                self.layer.setNeedsDisplay()
            })
        }
    }
    
    convenience init(frame: CGRect,textView: UITextView?) {
        self.init(frame: frame)
        
        NotificationCenter.default.addObserver(forName: UIView.keyboardDidChangeFrameNotification, object: textView, queue: nil) { [weak self] _ in
            self?.layer.setNeedsDisplay()
        }
        
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: textView, queue: nil) { [weak self] _ in
            self?.layer.setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias LinePoint = (start: CGPoint,end: CGPoint)
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        let context = ctx
        
        guard
            let textView = textView
        else {
            return
        }
        let textLayoutManager = textView.layoutManager
        
        let isFlipped: Bool = true
        context.saveGState()
        context.textMatrix = CGAffineTransform(scaleX: 1, y: isFlipped ? -1 : 1)
        
        var paragraphRanges: [NSRange] = []
        guard let text = textView.text else { return }
        
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex , options: .byParagraphs, { (
            substring, substringRange, _, _) in
            let nsRange = NSRange(substringRange, in: text)
            paragraphRanges.append(nsRange)
        })
        
        var lineNum = 1
        
        paragraphRanges.forEach{ range in
            var start_line: CGPoint = CGPoint(x: 0, y: 0)
            var end_line: CGPoint = CGPoint(x: 0, y: 0)
            var beforeRange: NSRange = NSRange(location: NSNotFound, length: 0)
            
            textLayoutManager.enumerateEnclosingRects(forGlyphRange: range,
                                                      withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                                                      in: textView.textContainer,
                                                      using: {
                rect, objcBool in
                // 같은 Paragraph의 range일때는 라인number를 생략하여 진행한다.
                if beforeRange == range{
                    (start_line,end_line) = self.getLinePoint(rect)
                    return
                }
                self.addDrawingText(rect, context: context, line: lineNum)
                (start_line,end_line) = self.getLinePoint(rect)
                lineNum += 1
                beforeRange = range
            })
            self.drawingLine(line: (start_line,end_line), context: context)
        }
        context.restoreGState()
    }
    
    private func drawingLine(_ color: CGColor = UIColor.black.cgColor,
                             _ width: CGFloat = 1.0,
                             line point: LinePoint,
                             context: CGContext){
        context.setStrokeColor(color)
        context.setLineWidth(width)
        context.move(to: point.start)
        context.addLine(to: point.end)
        context.strokePath()
    }
    
    private func getLinePoint(_ rect: CGRect, _ lineSpacing: CGFloat = 6) -> LinePoint{
        guard let textView else { return (CGPoint(x: NSNotFound, y: NSNotFound),CGPoint(x: NSNotFound, y: NSNotFound)) }
        let start_line = CGPoint(x: 0,
                             y: rect.origin.y + rect.height +  textView.textContainerInset.top + lineSpacing)
        let end_line = CGPoint(x: self.frame.width, y: start_line.y)
        return (start_line, end_line)
    }
    
    private func addDrawingText(_ rect: CGRect, context: CGContext, line number: Int) {
        guard let textView else {return}

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ]
        
        let frame = CGRect(x: rect.origin.x,
                           y: rect.origin.y + textView.textContainerInset.top,
                           width: rect.width,
                           height: rect.height)
        
        var numberText: String = "\(number)"
        
        if number % 10 == number{
            numberText.insert(contentsOf: "  ", at: numberText.startIndex)
        }
        
        let ctline = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(number)" as CFString, attributes as CFDictionary))
        
        context.textPosition = frame.origin.applying(.init(translationX: 5, y: 12))
        let font = attributes[.font] as! UIFont
        
        CTLineDraw(ctline, context)
    }

}


