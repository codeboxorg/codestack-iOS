//
//  NumberLinesView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit
import CoreImage
import CoreFoundation
import Global

public protocol TextViewSizeTracker: AnyObject {
    func updateNumberViewsHeight(_ height: CGFloat)
}

public protocol ChangeSelectedRange: AnyObject {
    func handle()
    func shouldHandleFocus() -> Bool
    func removeLayer()
}

public final class LineNumberRulerView: UIView, ChangeSelectedRange {

    private weak var textView: UITextView?
    private var textViewContentObserver: NSKeyValueObservation?
    private weak var tracker: TextViewSizeTracker?
    
    private lazy var updateContentSize: (CGSize) -> () = {[weak self] size in
        self?.tracker?.updateNumberViewsHeight(size.height)
        self?.layer.setNeedsDisplay()
    }
    
    public var number_100_Width: CGFloat {
        ("100" as NSString).size(withAttributes: self.attributes).width + 5
    }
    
    public var attributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 14),
        .foregroundColor : UIColor.systemGray
    ]
    
    private var lastParagraphRange: NSRange?
    
    //MARK: init process
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public convenience init(frame: CGRect,textView: UITextView?) {
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
    
    private func focusBackgroundColor() -> UIColor {
        let baseColor = self.backgroundColor ?? .white
        let highlightColor: UIColor

        if baseColor.isLight {
            highlightColor = UIColor.black.withAlphaComponent(0.05)
        } else {
            highlightColor = UIColor.white.withAlphaComponent(0.05)
        }
        
        return highlightColor
    }
    
    public func shouldHandleFocus() -> Bool {
        let selectedRange = textView!.selectedRange
        let nsText = textView!.text as NSString
        let paragraphRange = nsText.paragraphRange(for: selectedRange)

        if paragraphRange == lastParagraphRange {
            return false
        }
        return true
    }
    
    public func removeLayer() {
        self.layer.sublayers?.removeAll(where: { $0.name == "LineHighlightLayer" })
        self.textView?.layer.sublayers?.removeAll(where: { $0.name == "LineHighlightLayer" })
    }
    
    public func handle() {
        guard let textView = textView else { return }
        let selectedRange = textView.selectedRange
        let nsText = textView.text as NSString
        let paragraphRange = nsText.paragraphRange(for: selectedRange)
        
        lastParagraphRange = paragraphRange
        
        removeLayer()
        
        let highlightColor = focusBackgroundColor()
        let layoutManager = textView.layoutManager
        let glyphRange = layoutManager.glyphRange(forCharacterRange: paragraphRange, actualCharacterRange: nil)
        
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { rect, _, _, _, _ in
            let lineRect = rect.offsetBy(dx: 0, dy: textView.textContainerInset.top)
            let rulerLayer = CALayer()
            rulerLayer.name = "LineHighlightLayer"
            rulerLayer.frame = CGRect(x: 0, y: lineRect.origin.y - 4, width: self.bounds.width, height: lineRect.height)
            rulerLayer.backgroundColor = highlightColor.withAlphaComponent(0.2).cgColor
            self.layer.addSublayer(rulerLayer)

            let textViewLayer = CALayer()
            textViewLayer.name = "LineHighlightLayer"
            textViewLayer.frame = CGRect(x: 0, y: lineRect.origin.y - 4, width: textView.bounds.width, height: lineRect.height)
            textViewLayer.backgroundColor = highlightColor.withAlphaComponent(0.15).cgColor
            textView.layer.insertSublayer(textViewLayer, at: 0)
        }
    }
    
    //MARK: draw Process
    public typealias LinePoint = (start: CGPoint,end: CGPoint)
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
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
        
        paragraphRanges.forEach { [weak self] range in
            guard let self else { return }
            var start_line:  CGPoint = CGPoint(x: 0, y: 0)
            var end_line:    CGPoint = CGPoint(x: 0, y: 0)
            var beforeRange: NSRange = NSRange(location: NSNotFound, length: 0)
            textLayoutManager.enumerateEnclosingRects(
                forGlyphRange: range,
                withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0),
                in: textView.textContainer,
                using: { rect, _ in
                    // 같은 Paragraph의 range일때는 라인number를 생략하여 진행한다.
                    if beforeRange == range {
                        (start_line,end_line) = self.getLinePoint(rect)
                        return
                    }
                    
                    self.addDrawingText(
                        rect: rect,
                        context: context,
                        line: lineNum
                    )
                    
                    (start_line, end_line) = self.getLinePoint(rect)
                    lineNum += 1
                    beforeRange = range
                }
            )
            self.drawingLine(line: (start_line, end_line), context: context)
        }
        layer.isHidden = false
    }
    
    //MARK: textView setting
    public func settingTextView(_ textView: UITextView, tracker delegate: TextViewSizeTracker?) {
        self.textView = textView
        self.tracker = delegate
        
        if !textView.text.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self else {return}
                self.layer.setNeedsDisplay()
            })
        }
        guard let codeTextView = self.textView else {return}
        keyValueObserving(textView: codeTextView)
    }
    
    //MARK: TextView contentSize KVO
    private func keyValueObserving(textView: UITextView){
        textViewContentObserver = textView.observe(\.contentSize,options: [.new], changeHandler: { [weak self] ui, value in
            guard let self else { return }
            guard let newValue = value.newValue else {return}
            self.updateContentSize(newValue)
        })
    }
    
    //MARK: Custom Draw func
    private func drawingLine(
        _ color: CGColor = UIColor.systemGray2.cgColor,
        _ width: CGFloat = 1.0,
        line point: LinePoint,
        context: CGContext)
    {
        context.saveGState()
        context.setStrokeColor(color)
        context.setLineWidth(width)
        context.move(to: point.start)
        context.addLine(to: point.end)
        context.strokePath()
        context.restoreGState()
    }
    
    private func getLinePoint(_ rect: CGRect, _ lineSpacing: CGFloat = 6) -> LinePoint {
        guard let textView else {
            return (CGPoint(x: NSNotFound, y: NSNotFound), CGPoint(x: NSNotFound, y: NSNotFound))
        }
        
        let start_line = CGPoint(
            x: 0,
            y: rect.origin.y + rect.height + textView.textContainerInset.top + lineSpacing
        )
        
        let end_line = CGPoint(x: self.frame.width, y: start_line.y)
        
        return (start_line, end_line)
    }
    
    private func addDrawingText(
        rect: CGRect,
        context: CGContext,
        line number: Int
    ) {
        
        guard let textView else {
            return
        }
        
        let frame = CGRect(
            x: rect.origin.x,
            y: rect.origin.y + textView.textContainerInset.top,
            width: rect.width,
            height: rect.height
        )
        
        context.saveGState()
        
        let numberFont = attributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 14)
        let numberLineHeight = numberFont.lineHeight
        
        let codeFont = textView.font ?? UIFont.systemFont(ofSize: 14)
        let codeLineHeight = codeFont.lineHeight

        let padding = max(5, (codeLineHeight - numberLineHeight))
        let yOffset = numberLineHeight / 2 + padding

        let attributedString = NSAttributedString(string: "\(number)", attributes: attributes)
        let ctLine = CTLineCreateWithAttributedString(attributedString as CFAttributedString)

        let lineWidth = CTLineGetTypographicBounds(ctLine, nil, nil, nil)
        let xOffset = (self.bounds.width - CGFloat(lineWidth)) / 2

        context.textPosition = frame.origin.applying(.init(translationX: xOffset, y: yOffset))
        CTLineDraw(ctLine, context)
        
        context.restoreGState()
    }
}
