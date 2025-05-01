import UIKit
import CommonUI

final class CursorLayoutManager: CusorHighlightProtocol {
    
    struct Dependency {
        var changeSelectedRange: ChangeSelectedRange
        var textView: UITextView
        var suggestionManager: SuggestionManager
    }
    
    private weak var changeSelectedRange: ChangeSelectedRange?
    private weak var textView: UITextView?
    private weak var suggestionManager: SuggestionManager?
    
    private(set) lazy var removeLayoutAction: () -> Void = { [weak self] in
        self?.changeSelectedRange?.removeLayer()
        self?.removeHightLight()
        self?.suggestionManager?.removeSuggestionView()
    }
    
    init(
        changeSelectedRange: ChangeSelectedRange?,
        textView: UITextView?,
        suggestionManager: SuggestionManager?
    ) {
        self.changeSelectedRange = changeSelectedRange
        self.textView = textView
        self.suggestionManager = suggestionManager
    }
    
    private(set) lazy var cursorCommands: [CursorCommand] = [
        FocusCursorCommand.init(line: self.changeSelectedRange),
        BracketPairCursorCommand.init(editor: self.textView, highlightor: self),
        SuggestFocusCusorCommand(suggestionManager: self.suggestionManager)
    ]
    
    func executeWhenChangingLayoutSelection() {
        for cursorCommand in cursorCommands where cursorCommand.shouldHandle {
            cursorCommand.execute()
        }
    }
    
    func removeHightLight() {
        textView?.layer.sublayers?.removeAll(where: { $0.name == "BracketPairCursor" })
    }
    
    
    func highlight(first fRange: NSRange, second sRange: NSRange) {
        guard let textView else {
            return
        }
        
        let firstRect = textView.layoutManager.boundingRect(forGlyphRange: fRange, in: textView.textContainer)
        let secondRect = textView.layoutManager.boundingRect(forGlyphRange: sRange, in: textView.textContainer)

        let _firstRect = firstRect.offsetBy(dx: textView.textContainerInset.left, dy: textView.textContainerInset.top)
        let _secondRect = secondRect.offsetBy(dx: textView.textContainerInset.left, dy: textView.textContainerInset.top)

        let bracketFirstLayer = CALayer()
        bracketFirstLayer.name = "BracketPairCursor"
        bracketFirstLayer.frame = _firstRect.insetBy(dx: -2, dy: -2)
        bracketFirstLayer.borderColor = UIColor.systemGray.withAlphaComponent(0.8).cgColor
        bracketFirstLayer.borderWidth = 1.5
        bracketFirstLayer.cornerRadius = 4
        bracketFirstLayer.backgroundColor = UIColor.clear.cgColor
        self.textView?.layer.insertSublayer(bracketFirstLayer, at: 1)

        let bracketSecondLayer = CALayer()
        bracketSecondLayer.name = "BracketPairCursor"
        bracketSecondLayer.frame = _secondRect.insetBy(dx: -2, dy: -2)
        bracketSecondLayer.borderColor = UIColor.systemGray.withAlphaComponent(0.8).cgColor
        bracketSecondLayer.borderWidth = 1.5
        bracketSecondLayer.cornerRadius = 4
        bracketSecondLayer.backgroundColor = UIColor.clear.cgColor
        self.textView?.layer.insertSublayer(bracketSecondLayer, at: 1)
    }
}
