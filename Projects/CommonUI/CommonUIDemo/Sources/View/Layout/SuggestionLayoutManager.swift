import UIKit
import CommonUI
import Global
import Combine

protocol SuggestionLayout: AnyObject {
    var state: SuggestionLayoutState { get set }
}

enum SuggestionLayoutState {
    case focusing(
        [String],
        selectAction: (String) -> Void,
        gestureAction: (String) -> Void
    )
    case none
}

enum GestureFocusingItemState {
    case focusing(String)
    case none
}

final class SuggestionLayoutManager: SuggestionLayout {
    weak var editor: UITextView?
    
    private var _state = CurrentValueSubject<SuggestionLayoutState, Never>(.none)
    private var cancellables = Set<AnyCancellable>()
    
    var state: SuggestionLayoutState {
        get { _state.value }
        set { _state.send(newValue) }
    }
    
    var gestureFocusingItemState: GestureFocusingItemState = .none
    
    init(editor: UITextView?) {
        self.editor = editor
        _state.sink(
            receiveCompletion: { [weak self] _ in
                guard let self else { return }
                self.removeSuggestionView()
            },
            receiveValue: { [weak self] state in
                guard let self else { return }
                switch state {
                case .focusing(let words, let selectAction, let gestureAction):
                    self.showSuggestion(
                        suggestions: words,
                        selectAction: selectAction,
                        gestureAction: gestureAction
                    )
                case .none:
                    self.removeSuggestionView()
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func showSuggestion(
        suggestions: [String],
        selectAction: @escaping (String) -> Void,
        gestureAction: @escaping (String) -> Void
    ) {
        guard let rect = self.cursorPosition() else {
            return
        }
        
        removeSuggestionView()

        let suggestionView = SuggestionView(
            suggestions: [],
            selectAction: selectAction,
            gestureAction: gestureAction
        )
        
        suggestionView.updateSuggestions(words: suggestions)

        let lineHeight: CGFloat = suggestionView.tableView.rowHeight
        let viewHeight = CGFloat(min(suggestions.count, 5)) * lineHeight + 4
        
        suggestionView.frame = CGRect(
            x: rect.minX,
            y: rect.maxY + 4,
            width: 150,
            height: viewHeight
        )
        self.editor?.addSubview(suggestionView)
    }
    
    private func removeSuggestionView() {
        self.editor?.subviews
            .filter { $0 is SuggestionView }
            .forEach { $0.removeFromSuperview() }
    }
    
    private func cursorPosition() -> CGRect? {
        guard let editor, let selectedTextRange = editor.selectedTextRange?.end else {
            return nil
        }
        let caretRect = editor.caretRect(for: selectedTextRange)
        return editor.convert(caretRect, to: editor)
    }
}
