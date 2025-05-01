import CommonUI
import UIKit
import Global

final class EditorController: NSObject {
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
    private weak var widthUpdater            : TextViewWidthUpdateProtocol!
    private weak var suggestLayoutManager    : SuggestionLayout!
    private weak var undoableManager         : UndoableManager!
    private weak var suggestionManager       : SuggestionManager!
    private let buttonCommandExecuteManager  : ButtonCommandExecuteManager
    private let textInputCommandExcuteManager: TextInputCommandExcuteManager
    
    private(set) var inputViewLayoutManager  : InputViewLayoutManager!
    private var textViewWidthLayoutManager = TextViewWidthLayoutManager()
    private var cusorLayoutManager           : CursorLayoutManager!
    
    init(dependency: Dependency) {
        self.textView                      = dependency.textView
        self.widthUpdater                  = dependency.widthUpdater
        self.suggestLayoutManager          = dependency.suggestionLayout
        self.buttonCommandExecuteManager   = dependency.buttonCommandExecuteManager
        self.textInputCommandExcuteManager = dependency.textInputCommandExcuteManager
        self.undoableManager               = dependency.undoableManager
        self.suggestionManager             = dependency.suggestionManager
        
        defer {
            self.cusorLayoutManager = CursorLayoutManager(
                changeSelectedRange: dependency.changeSelecteRange,
                textView: self.textView,
                suggestionManager: self.suggestionManager
            )
            
            self.inputViewLayoutManager = InputViewLayoutManager(textView: self.textView)
            { [weak self] in
                self?.cusorLayoutManager.removeLayoutAction()
            } inputViewHideAction: { [weak buttonCommandExecuteManager] in
                guard let symbolAlert = buttonCommandExecuteManager?.symbolAlert else {
                    return
                }
                EditorButtonGenerator.symbolAlertColorAction(button: symbolAlert)
            }
            
            self.buttonCommandExecuteManager.replaceInputViewDelegate = self.inputViewLayoutManager
            let (toolbar, height) = ToolBarGenerator.makeToolBar(buttonCommandExecuteManager.allCommandButtons)
            
            self.inputViewLayoutManager.toolBarHeight = height
            self.textView?.inputAccessoryView = toolbar
            self.textView?.delegate = self
            self.inputViewLayoutManager.getKeyboardHegiht()
            self.inputViewLayoutManager.delegate = self
        }
        super.init()
    }
}

extension EditorController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        (suggestionManager as? SuggestionLayoutGenerator)?.suggestionLayoutGenerate()
        if let (oldTextRange, range, text) = SystemInsertSnapShot.shared.useWhenTextDidChange {
            textInputCommandExcuteManager.systemInsertActionSnapShot(oldTextRange: oldTextRange, shouldChangeTextIn: range, replacementText: text)
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
        cusorLayoutManager.executeWhenChangingLayoutSelection()
        widthUpdater?.positioningScrollView()
    }
}


extension EditorController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat
    {
        return 10
    }
}
