import UIKit
import CommonUI
import Combine

protocol EditorWrapper: UIView {
    func applyTheme(_ theme: String)
    func resignTextView()
    var code: String { get }
}


final class DefaultEditorWrapper: UIView,
                                  EditorWrapper,
                                  NSLayoutManagerDelegate {
    var code: String {
        editor.text
    }
    
    private var editor             : Editor { self.editorContainerView.codeUITextView }
    private var changeSelected     : ChangeSelectedRange { self.editorContainerView.numbersView as ChangeSelectedRange }
    private var textViewWidthUpdate: TextViewWidthUpdateProtocol { self.editorContainerView as TextViewWidthUpdateProtocol }
    
    private(set) var editorContainerView = EditorContainerView.init(frame: .zero)
    
    private lazy var undoableManager  : UndoableManager  = DefaultUndoableManager(editor: self.editor)
    private lazy var suggestionLayout : SuggestionLayout = SuggestionLayoutManager(editor: self.editor)
    private let wordSuggestion: WordSuggenstion  = DefaultWordSuggenstion()
    private lazy var suggestionManager: SuggestionManager = DefaultSuggestionManager(
       dependency: .init(
           suggestion: self.wordSuggestion,
           editor: self.editor,
           suggestionLayout: self.suggestionLayout,
           suggestionCommand: SuggestionCommand(
               editor: self.editor,
               invoker: self.undoableManager
           )
       )
   )
    private lazy var editorController = EditorController(
        dependency: .init(
            textView: self.editor,
            changeSelecteRange: self.changeSelected,
            widthUpdater: self.textViewWidthUpdate,
            undoableManager: self.undoableManager,
            suggestionManager: self.suggestionManager,
            suggestionLayout: self.suggestionLayout,
            textInputCommandExcuteManager: DefaultTextInputCommandExcuteManager(
                editor: self.editor,
                undoableManager: self.undoableManager,
                textRangeResolver: TextRangeResolver(editor: self.editor),
                textInputCommands:
                SuggestionEnterCommand(suggestionManager: self.suggestionManager as? SuggestionInsert),
                SuggestionGeneratorCommand(suggestionManager: self.suggestionManager as? SuggestionGenerator),
                EnterCommand(suggestionLayout: self.suggestionLayout, commandExecutor: self.editor),
                AutoRemoveCommand(commandExecutor: self.editor),
                AutoPairCharacterCommand(commandExecutor: self.editor)
            ),
            buttonCommandExecuteManager: DefaultButtonCommandExecuteManager(
                editor: self.editor,
                undoableManager: self.undoableManager
            )
        )
    )
    
    private var bottomConstraint: NSLayoutConstraint?
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutConfigure()
        addKeyboardObserver()
        self.editor.undoableManager = undoableManager
        editorContainerView.codeUITextView.layoutManager.delegate = self
        editorContainerView.codeUITextView.delegate = self.editorController
    }
    
    required init?(coder: NSCoder) { fatalError("never call") }
    
    private func addKeyboardObserver() {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] notification in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
                UIView.animate(withDuration: duration) {
                    self.bottomConstraint?.constant = -(keyboardFrame.height - self.editorController.inputViewLayoutManager.toolBarHeight)
                    self.layoutIfNeeded()
                }
            })
            .store(in: &subscriptions)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] notification in
                guard let self = self,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

                UIView.animate(withDuration: duration) {
                    self.bottomConstraint?.constant = 0
                    self.layoutIfNeeded()
                }
            })
            .store(in: &subscriptions)
    }
    
    private func layoutConfigure() {
        self.addSubview(editorContainerView)
        editorContainerView.translatesAutoresizingMaskIntoConstraints = false

        let top = editorContainerView.topAnchor.constraint(equalTo: self.topAnchor)
        let leading = editorContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailing = editorContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let bottom = editorContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        self.bottomConstraint = bottom

        NSLayoutConstraint.activate([top, leading, trailing, bottom])
    }
    
    func resignTextView() {
        if editorContainerView.codeUITextView.isFirstResponder {
           editorContainerView.codeUITextView.resignFirstResponder()
        }
    }
    
    func applyTheme(_ theme: String) {
        self.editorContainerView.highlightr?.setTheme(to: theme)
        let color = self.editorContainerView.highlightr?.theme.themeBackgroundColor
        self.editorContainerView.numberTextViewContainer.backgroundColor = color
        self.editorContainerView.codeUITextView.backgroundColor = color
        self.editorContainerView.numbersView.backgroundColor = color
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat
    {
        return 10
    }
}
