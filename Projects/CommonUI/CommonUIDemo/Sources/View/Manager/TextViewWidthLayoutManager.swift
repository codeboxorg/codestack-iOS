import UIKit


protocol TextViewWidthTrackable {
    var currentMaxWidth: CGFloat { get }
    func update(textView: UITextView) -> Bool
}

protocol TextViewWidthUpdateProtocol: AnyObject {
    func updateTextViewWidth(_ width: CGFloat)
    func positioningScrollView()
}

final class TextViewWidthLayoutManager: TextViewWidthTrackable {
    private(set) var currentMaxWidth: CGFloat = UIScreen.main.bounds.width
    private let minWidth: CGFloat = UIScreen.main.bounds.width
    private let maxWidth: CGFloat = UIScreen.main.bounds.width * 2
    private var maxLineIndex: Int = 0

    func update(textView: UITextView) -> Bool {
        guard let font = textView.font else { return false }
        let lines = textView.text.components(separatedBy: .newlines)
        let cursorIndex = textView.selectedRange.location
        let lineIndex = textView.text.lineIndex(at: cursorIndex)
        guard lines.indices.contains(lineIndex) else { return false }

        let line = lines[lineIndex]
        let newLineWidth = (line as NSString).size(withAttributes: [.font: font]).width + 40
        var widthChanged = false

        if newLineWidth > currentMaxWidth {
            currentMaxWidth = min(newLineWidth, maxWidth)
            maxLineIndex = lineIndex
            widthChanged = true
        } else if lineIndex == maxLineIndex {
            let maxInAll = lines.map {
                ($0 as NSString).size(withAttributes: [.font: font]).width
            }.max() ?? minWidth
            let newMaxWidth = max(minWidth, min(maxInAll + 40, maxWidth))
            if newMaxWidth != currentMaxWidth {
                currentMaxWidth = newMaxWidth
                maxLineIndex = lines.firstIndex(where: {
                    ($0 as NSString).size(withAttributes: [.font: font]).width == maxInAll
                }) ?? 0
                widthChanged = true
            }
        }
        
        return widthChanged
    }
}

private extension String {
    func lineIndex(at location: Int) -> Int {
        let index = self.index(self.startIndex, offsetBy: location, limitedBy: self.endIndex) ?? self.endIndex
        return self[..<index].components(separatedBy: .newlines).count - 1
    }
}
