import UIKit

final class InputViewLayoutManager: EditorReplaceInputView {
    enum KeyboardState {
        case keyboard
        case specialCharacters
        case none
    }
    
    var toolBarHeight: CGFloat = 0
    private var keyboardHeight: CGFloat = 0
    private var totalInputViewSize: CGFloat {
        keyboardHeight - toolBarHeight
    }
    
    private lazy var keyboardState: KeyboardState = .keyboard
    
    var action: () -> Void
    weak var textView: UITextView!
    weak var delegate: UITextViewDelegate!
    
    init(textView: UITextView?, _ action: @escaping () -> Void) {
        self.textView = textView
        self.action = action
    }
    
    func getKeyboardHegiht() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main)
        { [weak self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self?.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main)
        { [weak self] notification in
            guard let self else { return }
            self.action()
        }
    } 
    
    
    // MARK: Delegate repalceInputView when tapped SymbolAlert Button
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
                        let shouldChange = delegate!.textView!(textView, shouldChangeTextIn: selectedRange, replacementText: specialChar.rawValue)
                        if shouldChange {
                            guard let range = textView.textRange(from: textView.beginningOfDocument, offset: selectedRange.location, length: selectedRange.length) else {
                                return
                            }
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
        }
        textView?.reloadInputViews()
    }
    
}
