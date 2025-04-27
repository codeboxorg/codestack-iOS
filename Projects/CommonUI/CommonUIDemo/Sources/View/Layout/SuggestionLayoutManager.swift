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
        guard let rect = self.cursorPosition(), let editor = self.editor else {
            return
        }
        
        removeSuggestionView()

        let suggestionView = SuggestionView(
            suggestions: [],
            selectAction: selectAction,
            gestureAction: gestureAction
        )

        let updatedCount = suggestionView.updateSuggestions(words: suggestions)
        let lineHeight: CGFloat = suggestionView.tableView.rowHeight
        let viewHeight = CGFloat(min(updatedCount, 5)) * lineHeight + 4
        let viewWidth: CGFloat = 150
        var suggestionX = rect.minX
        
        if suggestionX + viewWidth > editor.bounds.width {
            
            suggestionX = max(0, rect.maxX - viewWidth)
        }
        
        suggestionView.frame = CGRect(
            x: suggestionX,
            y: rect.maxY + 4,
            width: viewWidth,
            height: viewHeight + (lineHeight / 3)
        )
        
        self.editor?.addSubview(suggestionView)
        suggestionView.reload()
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
