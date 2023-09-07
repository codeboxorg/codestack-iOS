//
//  NumberLinesView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import CoreImage
import CoreFoundation

protocol TextViewSizeTracker: AnyObject{
    func updateNumberViewsHeight(_ height: CGFloat)
}

class LineNumberRulerView: UIView {
    private weak var textView: UITextView?
    private var textViewContentObserver: NSKeyValueObservation?
    private weak var tracker: TextViewSizeTracker?
    private lazy var updateContentSize: (CGSize) -> () = {[weak self] size in
        self?.tracker?.updateNumberViewsHeight(size.height)
        self?.layer.setNeedsDisplay()
    }
    
    private var attributes: [NSAttributedString.Key : Any] {
        [
           .font: UIFont.boldSystemFont(ofSize: 14),
           .foregroundColor: UIColor.systemGray
        ]
    }
    
    //MARK: init process
    override init(frame: CGRect) {
        super.init(frame: frame)
     
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
    
    
    //MARK: draw Process
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
        context.restoreGState()
        
        var paragraphRanges: [NSRange] = []
        guard let text = textView.text else { return }
        
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex , options: .byParagraphs, { (
            substring, substringRange, _, _) in
            let nsRange = NSRange(substringRange, in: text)
            paragraphRanges.append(nsRange)
        })
        
        var lineNum = 1
        
        paragraphRanges.forEach{ [weak self] range in
            guard let self else { return }
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
                
                self.addDrawingText(rect, context: context, line: lineNum, attributes: self.attributes )
                (start_line,end_line) = self.getLinePoint(rect)
                lineNum += 1
                beforeRange = range
                
            })
            self.drawingLine(line: (start_line,end_line), context: context)
        }
        
        layer.isHidden = false
    }
    
    
    //MARK: textView setting
    func settingTextView(_ textView: UITextView,tracker delegate: TextViewSizeTracker ){
        self.textView = textView
        self.tracker = delegate
        self.backgroundColor = textView.backgroundColor
        
        if !textView.text.isEmpty{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self else {return}
                self.layer.setNeedsDisplay()
            })
        }
        guard let codeTextView = self.textView else {return}
        let kvo = codeTextView.observe(\.contentSize,options: [.new], changeHandler: { [weak self] ui, value in
            guard let self else { return }
            guard let newValue = value.newValue else {return}
            self.updateContentSize(newValue)
        })
        keyValueObserving(content: kvo)
    }
    
    //MARK: TextView contentSize KVO
    private func keyValueObserving(content observing: NSKeyValueObservation){
        textViewContentObserver = observing
    }
    
    
   
    //MARK: Custom Draw func
    private func drawingLine(_ color: CGColor = UIColor.systemGray2.cgColor,
                             _ width: CGFloat = 1.0,
                             line point: LinePoint,
                             context: CGContext){
        context.saveGState()
        context.setStrokeColor(color)
        context.setLineWidth(width)
        context.move(to: point.start)
        context.addLine(to: point.end)
        context.strokePath()
        context.restoreGState()
    }
    
    private func getLinePoint(_ rect: CGRect, _ lineSpacing: CGFloat = 6) -> LinePoint{
        guard let textView else { return (CGPoint(x: NSNotFound, y: NSNotFound),CGPoint(x: NSNotFound, y: NSNotFound)) }
        let start_line = CGPoint(x: 0,
                             y: rect.origin.y + rect.height +  textView.textContainerInset.top + lineSpacing)
        let end_line = CGPoint(x: self.frame.width, y: start_line.y)
        return (start_line, end_line)
    }
    
    private func addDrawingText(_ rect: CGRect,
                                context: CGContext,
                                line number: Int,
                                attributes: [NSAttributedString.Key : Any]) {
        guard let textView else {return}
        
        let frame = CGRect(x: rect.origin.x,
                           y: rect.origin.y + textView.textContainerInset.top,
                           width: rect.width,
                           height: rect.height)
        context.saveGState()
        
        if number < 100{
            context.textPosition = frame.origin.applying(.init(translationX: 5, y: 12))
        }else{
            context.textPosition = frame.origin.applying(.init(translationX: 0, y: 12))
        }
        
        let ctline = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(number)" as CFString, attributes as CFDictionary))
        CTLineDraw(ctline, context)
        context.restoreGState()
        
    }
}


