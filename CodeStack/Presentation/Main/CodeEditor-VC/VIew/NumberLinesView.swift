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
    
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        let context = ctx
        
        guard
            let textView = textView
        else {
            return
        }
        let textLayoutManager = textView.layoutManager
        
        
        let relativePoint = self.convert(CGPoint(), from: textView)
        let isFlipped: Bool = true
        context.saveGState()
        context.textMatrix = CGAffineTransform(scaleX: 1, y: isFlipped ? -1 : 1)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        
        var paragraphRanges: [NSRange] = []
        guard let text = textView.text else { return }
        
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex , options: .byParagraphs, { (
            substring, substringRange, _, _) in
            let nsRange = NSRange(substringRange, in: text)
            paragraphRanges.append(nsRange)
        })
        
        var lineNum = 1
        paragraphRanges.forEach{ range in
            
            textLayoutManager.enumerateEnclosingRects(forGlyphRange: range,
                                                      withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                                                      in: textView.textContainer,
                                                      using: {
                rect, objcBool in
                let location = textView.layoutManager.lineFragmentRect(forGlyphAt: range.location, effectiveRange: nil)
                let frame = CGRect(x: rect.origin.x,
                                   y: rect.origin.y + textView.textContainerInset.top,
                                   width: rect.width,
                                   height: rect.height)
                var numberText: String = "\(lineNum)"
                
                if lineNum % 10 == lineNum{
                    numberText.insert(contentsOf: "  ", at: numberText.startIndex)
                }
                
                var ctline = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "\(numberText)" as CFString, attributes as CFDictionary))
                
                context.textPosition = frame.origin.applying(.init(translationX: 5, y: 12))
                CTLineDraw(ctline, context)
                
                lineNum += 1
                
            })
        }
        
        context.restoreGState()
        
    }
}


