import CommonUI
import UIKit
import Global

final class EditorController: NSObject, EditorControl, CusorHighlightProtocol {
    enum KeyboardState {
        case keyboard
        case specialCharacters
        case none
    }
    
    struct Dependency {
        var textView: UITextView
        var lineNumberView: ChangeSelectedRange
        var widthUpdater: TextViewWidthUpdateProtocol?
    }
    
    weak var textView: UITextView?
    weak var lineNumberView: ChangeSelectedRange?
    weak var widthUpdater: TextViewWidthUpdateProtocol?
    
    let manager = TextViewWidthLayoutManager()
    
    var moveTimer: Timer?
    
    private lazy var keyboardState: KeyboardState = .keyboard
    private var keyboardHeight: CGFloat = 0
    private(set) var toolBarSize: CGFloat = 0
    private var totalInputViewSize: CGFloat {
        keyboardHeight - toolBarSize
    }
    
    
    private lazy var inputCommands: [TextInputCommand] = [
        AutoPairCharacterCommand(self.textView),
        EnterCommand(self.textView),
        AutoRemoveCommand(self.textView)
    ]
    
    private lazy var cursorCommands: [CursorCommand] = [
        FocusCursorCommand.init(line: self.lineNumberView),
        BracketPairCursorCommand.init(editor: self.textView, highlightor: self)
    ]
    
    init(dependency: Dependency) {
        super.init()
        self.textView = dependency.textView
        self.lineNumberView = dependency.lineNumberView
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
    
    private func getKeyboardHegiht() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main)
        { [weak self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self?.keyboardHeight = keyboardFrame.height
            }
        }
    }
}

extension EditorController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if manager.update(textView: textView) {
            widthUpdater?.updateTextViewWidth(manager.currentMaxWidth)
        }
        
        for command in inputCommands {
            if command.shouldHandle(text: text) {
                return command.execute(range: range, text: text)
            }
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        for cursorCommand in self.cursorCommands where cursorCommand.shouldHandle {
            cursorCommand.execute()
        }
    }
}


// MARK: Delegate repalceInputView when tapped SymbolAlert Button
extension EditorController: EditorReplaceInputView {
    func replaceInputView() {
        if keyboardState == .keyboard {
            let customInputView = SpecialCharacterInputView(
                inputViewHeight: totalInputViewSize,
                input: { [weak self] specialChar in
                    guard
                        let self,
                        let textView = self.textView
                    else {
                        return
                    }
                    if specialChar == SpecialLigature.back {
                        if let range = textView.selectedTextRange {
                            if range.isEmpty, let newPosition = textView.position(from: range.start, offset: -1),
                               let deleteRange = textView.textRange(from: newPosition, to: range.start) {
                                textView.replace(deleteRange, withText: "")
                            } else {
                                textView.replace(range, withText: "")
                            }
                        }
                    } else {
                        let selectedRange = textView.selectedRange
                        let shouldChange = self.textView(textView, shouldChangeTextIn: selectedRange, replacementText: specialChar.rawValue)
                        if shouldChange {
                            let range = textView.textRange(from: textView.beginningOfDocument, offset: selectedRange.location, length: selectedRange.length)
                            textView.replace(range, withText: specialChar.rawValue)
                        }
                    }
                    self.replaceInputView()
                }
            )
            customInputView.translatesAutoresizingMaskIntoConstraints = false
            self.keyboardState = .specialCharacters
            textView?.inputView = customInputView
            
        } else if keyboardState == .specialCharacters {
            self.keyboardState = .keyboard
            textView?.inputView = nil
            addDoneButtonOnKeyboard()
        }
        textView?.reloadInputViews()
    }
}



extension EditorController {
    var done: UIButton {
        EditorButtonGenerator.generate(type: .done(DoneCommand(editor: self.textView)))
    }
    
    var tapButton: UIButton {
        EditorButtonGenerator.generate(type: .tap(TapCommand(editor: self.textView)))
    }
    
    var moveLeftButton: UIButton {
        EditorButtonGenerator.generate(type: .moveLeft([
            MoveLeftCommand(editor: self.textView),
            MoveLeftTouchDownCommand(editor: self),
            MoveTouchUpCommand(editor: self),
            MoveTouchOutCommand(editor: self),
        ]))
    }
    
    var moveRightButton: UIButton {
        EditorButtonGenerator.generate(type: .moveRight([
            MoveRightCommand(editor: self.textView),
            MoveRightTouchDownCommand(editor: self),
            MoveTouchUpCommand(editor: self),
            MoveTouchOutCommand(editor: self)
        ]))
    }
    
    var symbolAlert: UIButton {
        EditorButtonGenerator.generate(type: .symbol(ReplaceInputViewCommand(controller: self)))
    }
    
    fileprivate func addDoneButtonOnKeyboard() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = .whiteGray

        let (scrollView, stackViewInScrollView) = _containerView()
        let buttons = [done, tapButton, moveLeftButton, moveRightButton, symbolAlert]
        let done = buttons[0]
        let separator1 = _makeSeparator()
        let separator2 = _makeSeparator()
        
        buttons[1...].enumerated().forEach { enumerated in
            let (offset, button) = enumerated
            if offset == 1 {
                stackViewInScrollView.addArrangedSubview(separator1)
            }
            stackViewInScrollView.addArrangedSubview(button)
        }
        
        let doneItem = UIBarButtonItem(customView: done)
        let separator = UIBarButtonItem(customView: separator2)
        let scrollItem = UIBarButtonItem(customView: scrollView)
        
        toolBar.items = [scrollItem, separator, doneItem]
        toolBar.sizeToFit()
        let toolBarSize = toolBar.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat(50)))
        self.toolBarSize = toolBarSize.height
        self.textView?.inputAccessoryView = toolBar
    }
}


// MARK: TOOLBAR - SUBVIEWS FUNCTION
extension EditorController {
    func _containerView() -> (UIScrollView, UIStackView) {
        let scrollView = __scrollViewiew()
        let stackView = __stackView()
        
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        return (scrollView, stackView)
    }
    
    func _makeSeparator(height: CGFloat = 20, color: UIColor = .lightGray, horizontalPadding: CGFloat = 4) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = color

        container.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: height)
        ])

        return container
    }
    
    private func __stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func __scrollViewiew() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 60, height: 44))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }
}

extension EditorController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}
