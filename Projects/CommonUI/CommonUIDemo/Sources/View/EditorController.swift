import CommonUI
import UIKit
import Global

final class EditorController: NSObject, CusorHighlightProtocol {
    enum KeyboardState {
        case keyboard
        case specialCharacters
        case none
    }
    
    struct Dependency {
        var textView: UITextView
        var lineNumberView: ChangeSelectedRange
        var widthUpdater: TextViewWidthUpdateProtocol?
        var buttonCommandExecuteManager: ButtonCommandExecuteManager
        var undoableManager: UndoableManager
    }
    
    
    weak var textView: UITextView?
    weak var lineNumberView: ChangeSelectedRange?
    weak var widthUpdater: TextViewWidthUpdateProtocol?
    
    private lazy var suggestLayoutManager: SuggestionLayout = SuggestionLayoutManager(editor: textView)
    
    private var buttonCommandExecuteManager: ButtonCommandExecuteManager!
    
    private let textViewWidthLayoutManager = TextViewWidthLayoutManager()
    
    private lazy var textInputCommandExcuteManager = TextInputCommandExcuteManager(
        editor: textView,
        undoableManager: undoableManager,
        suggestionManager: suggestionManager,
        suggestionLayoutManger: suggestLayoutManager
    )
    
    private var undoableManager: UndoableManager!
    
    private(set) lazy var suggestionManager: SuggestionManager = DefaultSuggestionManager(
        dependency: .init(
            suggestion: DefaultWordSuggenstion(),
            editor: self.textView,
            layoutManager: self.suggestLayoutManager,
            suggestionCommand: SuggestionCommand(
                editor: self.textView,
                invoker: self.undoableManager
            )
        )
    )
    
    private lazy var keyboardState: KeyboardState = .keyboard
    private var keyboardHeight: CGFloat = 0
    private(set) var toolBarSize: CGFloat = 0
    private var totalInputViewSize: CGFloat {
        keyboardHeight - toolBarSize
    }
    
    private lazy var cursorCommands: [CursorCommand] = [
        FocusCursorCommand.init(line: self.lineNumberView),
        BracketPairCursorCommand.init(editor: self.textView, highlightor: self),
        SuggestFocusCusorCommand(suggestionManager: self.suggestionManager)
    ]
    
    init(dependency: Dependency) {
        super.init()
        self.textView = dependency.textView
        self.lineNumberView = dependency.lineNumberView
        self.buttonCommandExecuteManager = dependency.buttonCommandExecuteManager
        self.undoableManager = dependency.undoableManager
        self.widthUpdater = dependency.widthUpdater
        buttonCommandExecuteManager.replaceInputViewDelegate = self
        
        suggestionManager.initSuggestion()
        addDoneButtonOnKeyboard()
        getKeyboardHegiht()
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
