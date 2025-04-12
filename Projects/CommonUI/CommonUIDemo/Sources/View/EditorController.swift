import CommonUI
import UIKit

final class EditorController: NSObject, EditorControl, UITextViewDelegate {
    internal weak var textView: UITextView?
    
    struct Dependency {
        var textView: UITextView
        var lineNumberView: ChangeSelectedRange
        var widthUpdater: TextViewWidthUpdateProtocol?
    }
    weak var textView: UITextView?
    weak var lineNumberView: ChangeSelectedRange?
    var moveTimer: Timer?
    
    private lazy var inputCommands: [TextInputCommand] = [
        AutoPairCharacterCommand(self.textView),
        EnterCommand(self.textView)
    private lazy var cursorCommands: [CursorCommand] = [
        FocusCursorCommand.init(line: self.lineNumberView),
        BracketPairCursorCommand.init(editor: self.textView, highlightor: self)
    ]
    
    init(dependency: Dependency) {
        super.init()
        self.textView = dependency.textView
        self.lineNumberView = dependency.lineNumberView
        addDoneButtonOnKeyboard()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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

extension EditorController {
    fileprivate func addDoneButtonOnKeyboard() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = .whiteGray

        let (scrollView, stackViewInScrollView) = _containerView()
        let buttons = makeCommandActionButton()
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

        self.textView?.inputAccessoryView = toolBar
    }
}


// MARK: MAKE COMMAND ACTION BUTTONS
extension EditorController {
    func makeCommandActionButton() -> [UIButton] {
        let done = EditorButtonGenerator.generate(type: .done(DoneCommand(editor: self.textView)))
        let tapButton = EditorButtonGenerator.generate(type: .tap(TapCommand(editor: self.textView)))
        
        let moveLeftButton = EditorButtonGenerator.generate(type: .moveLeft([
            MoveLeftCommand(editor: self.textView),
            MoveLeftTouchDownCommand(editor: self),
            MoveTouchUpCommand(editor: self),
            MoveTouchOutCommand(editor: self),
        ]))
        
        let moveRightButton = EditorButtonGenerator.generate(type: .moveRight([
            MoveRightCommand(editor: self.textView),
            MoveRightTouchDownCommand(editor: self),
            MoveTouchUpCommand(editor: self),
            MoveTouchOutCommand(editor: self)
        ]))
        return [done, tapButton, moveLeftButton, moveRightButton]
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
