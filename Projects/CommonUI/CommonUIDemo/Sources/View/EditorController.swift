import CommonUI
import UIKit
import Global

final class EditorController: NSObject, CusorHighlightProtocol {
    struct Dependency {
        var textView                     : UITextView?
        var changeSelecteRange           : ChangeSelectedRange?
        var widthUpdater                 : TextViewWidthUpdateProtocol?
        var undoableManager              : UndoableManager
        var suggestionManager            : SuggestionManager
        var suggestionLayout             : SuggestionLayout
        var textInputCommandExcuteManager: TextInputCommandExcuteManager
        var buttonCommandExecuteManager  : ButtonCommandExecuteManager
    }
    
    private(set) weak var textView           : UITextView!
    private weak var changeSelecteRange      : ChangeSelectedRange!
    private weak var widthUpdater            : TextViewWidthUpdateProtocol!
    private weak var suggestLayoutManager    : SuggestionLayout!
    private weak var undoableManager         : UndoableManager!
    private weak var suggestionManager       : SuggestionManager!
    private let buttonCommandExecuteManager  : ButtonCommandExecuteManager
    private let textInputCommandExcuteManager: TextInputCommandExcuteManager
    
    private(set) var inputViewLayoutManager  : InputViewLayoutManager!
    private var textViewWidthLayoutManager = TextViewWidthLayoutManager()
    
    private lazy var cursorCommands: [CursorCommand] = [
        FocusCursorCommand.init(line: self.changeSelecteRange),
        BracketPairCursorCommand.init(editor: self.textView, highlightor: self),
        SuggestFocusCusorCommand(suggestionManager: self.suggestionManager)
    ]
    
    init(dependency: Dependency) {
        self.textView                      = dependency.textView
        self.changeSelecteRange            = dependency.changeSelecteRange
        self.widthUpdater                  = dependency.widthUpdater
        self.suggestLayoutManager          = dependency.suggestionLayout
        self.buttonCommandExecuteManager   = dependency.buttonCommandExecuteManager
        self.textInputCommandExcuteManager = dependency.textInputCommandExcuteManager
        self.undoableManager               = dependency.undoableManager
        self.suggestionManager             = dependency.suggestionManager
        
        defer {
            self.inputViewLayoutManager = InputViewLayoutManager(textView: self.textView)
            { [weak self] in
                self?.changeSelecteRange?.removeLayer()
                self?.removeHightLight()
                self?.suggestionManager.removeSuggestionView()
            }
            
            self.buttonCommandExecuteManager.replaceInputViewDelegate = self.inputViewLayoutManager
            let (toolbar, height) = ToolBarGenerator.makeToolBar(buttonCommandExecuteManager.allCommandButtons)
            self.inputViewLayoutManager.toolBarHeight = height
            self.textView?.inputAccessoryView = toolbar
            self.textView?.delegate = self
            self.inputViewLayoutManager.getKeyboardHegiht()
        }
        super.init()
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

extension EditorController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        suggestionManager.suggestionLayoutGenerate()
        if let (oldTextRange, range, text) = SystemInsertSnapShot.shared.useWhenTextDidChange {
            textInputCommandExcuteManager
                .systemInsertActionSnapShot(
                    oldTextRange: oldTextRange,
                    shouldChangeTextIn: range,
                    replacementText: text
                )
            SystemInsertSnapShot.shared.useWhenTextDidChange = nil
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textViewWidthLayoutManager.update(textView: textView) {
            widthUpdater?.updateTextViewWidth(textViewWidthLayoutManager.currentMaxWidth)
        }
        return textInputCommandExcuteManager.commandExecute(shouldChangeTextIn: range, replacementText: text)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        for cursorCommand in self.cursorCommands where cursorCommand.shouldHandle {
            cursorCommand.execute()
        }
        widthUpdater?.positioningScrollView()
    }
}


extension EditorController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat
    {
        return 10
    }
}
