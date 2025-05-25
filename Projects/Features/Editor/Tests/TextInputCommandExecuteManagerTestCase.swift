@testable import Editor
import XCTest


final class TextInputCommandExecuteManagerTestCase: XCTestCase {
    
    var mockDelegate: MockEditorDelegate!
    var manager: DefaultTextInputCommandExcuteManager!
    var suggestionLayout: SuggestionLayout!
    var suggestionManager: CompositeSuggestionManager!
    var wordSuggestion: WordSuggenstion!
    var undoableManager: DefaultUndoableManager!
    var editor: Editor!
    
    override func setUpWithError() throws {
        let _editor = Editor()
        
        
        undoableManager = DefaultUndoableManager.init(editor: _editor)
        wordSuggestion = DefaultWordSuggenstion()
        
        suggestionLayout = MockSuggestionLayout()
        
        let suggestionCommand = SuggestionCommand(editor: _editor, invoker: undoableManager)
        
        suggestionManager = DefaultSuggestionManager(
            dependency: .init(
                suggestion: wordSuggestion,
                editor: editor,
                suggestionLayout: suggestionLayout,
                suggestionCommand: suggestionCommand
            )
        )
        
        manager = DefaultTextInputCommandExcuteManager.init(
            editor: _editor,
            undoableManager: self.undoableManager,
            textRangeResolver: TextRangeResolver(editor: _editor),
            textInputCommands:
                SuggestionEnterCommand(suggestionManager: self.suggestionManager as SuggestionInsert),
            SuggestionGeneratorCommand(suggestionManager: self.suggestionManager as SuggestionGenerator),
            EnterCommand(suggestionLayout: self.suggestionLayout, commandExecutor: _editor),
            AutoRemoveCommand(commandExecutor: _editor),
            AutoPairCharacterCommand(commandExecutor: _editor)
        )
        
        mockDelegate = MockEditorDelegate.init(
            textInputCommandExcuteManager: manager,
            suggestionManager: suggestionManager,
            cusorCommand: SuggestFocusCusorCommand(suggestionManager: self.suggestionManager)
        )
        _editor.delegate = mockDelegate
        _editor.undoableManager = undoableManager
        editor = _editor
    }
    
    override func tearDownWithError() throws {
        manager = nil
        editor = nil
        suggestionLayout = nil
        suggestionManager = nil
        wordSuggestion = nil
        undoableManager = nil
    }
    
    //    AutoPairCharacterCommand
    func test_autoPair_character_command() {
        editor.text = "Hello"
        editor.selectedRange = NSRange(location: 5, length: 0)
        
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: 5, length: 0), replacementText: "(")
        
        XCTAssertFalse(systemUpdate)
        XCTAssertEqual(editor.text, "Hello()")
    }
    
    //    AutoRemoveCommand
    func test_auto_remove_command() {
        editor.text = "solution()"
        
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: 8, length: 1), replacementText: "")
        
        XCTAssertFalse(systemUpdate)
        XCTAssertEqual(editor.text, "solution")
    }
    
    //    EnterCommand
    func test_enter_command() {
        // Given
        let prior = """
func solution(_ arr: [Int], _ value: [String]) {
    for i in arr {}
}
"""
        let after = """
func solution(_ arr: [Int], _ value: [String]) {
    for i in arr {
        
    }
}
"""
        editor.text = prior
        editor.selectedRange = NSRange(location: 67, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: 67, length: 0), replacementText: "\n")
        
        
        // Then
        XCTAssertFalse(systemUpdate)
        XCTAssertEqual(
            editor.text.replacingOccurrences(of: "\t", with: "    "),
            after
        )
    }
    
    //    SuggestionEnterCommand
    func test_suggestion_enter_command() {
        // Given
        let prior = "func sol"
        editor.text = prior
        editor.selectedRange = NSRange(location: prior.count, length: 0)
        suggestionManager.currentFocusingItem = "solution"
        suggestionLayout.state = .focusing(
            [],
            selectAction: { _ in },
            gestureAction: { _ in }
        )
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: 8, length: 0), replacementText: "\n")
        
        // Then
        XCTAssertFalse(systemUpdate)
        XCTAssertEqual(
            editor.text,
            "func solution"
        )
    }
    
    
    //    SuggestionGeneratorCommand
    func test_suggestion_generator_command() {
        // Given
        let prior = "func"
        editor.text = prior
        editor.selectedRange = NSRange(location: prior.count, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: 4, length: 0), replacementText: " ")
        
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(wordSuggestion.suggest(for: "f").map(\.word), ["func"])   
    }
    
    //    SuggestionGeneratorCommand
    func test_suggestion_generator_command2() {
        // Given
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: prior.count, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: NSRange(location: prior.count, length: 0), replacementText: " ")
        
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(wordSuggestion.suggest(for: "s").map(\.word), ["solution"])
    }
    
    
    // systemReplaceActionSnapShot(shouldChangeTextIn:, replacementText:)
    func test_replace_undoable() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "S")
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(undoableManager.isUndoable, true)
        XCTAssertEqual(undoableManager.undoManager.undoActionName, ActionCommandType.systemReplace.rawValue)
    }
    
    func test_remove_undoable() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "")
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(undoableManager.isUndoable, true)
        XCTAssertEqual(undoableManager.undoManager.undoActionName, ActionCommandType.systemRemove.rawValue)
    }
    
    func test_input_undoable() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 13, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "s")
        editor.insertText("s")
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(undoableManager.isUndoable, true)
        XCTAssertEqual(undoableManager.undoManager.undoActionName, ActionCommandType.systemInput.rawValue)
    }
    
    func test_replace_undo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "S")
        editor.replace(editor.textRange(from: editor.selectedRange)!, withText: "S")
        
        undoableManager.undo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, prior)
        XCTAssertEqual(editor.selectedRange, NSRange(location: 5, length: 8))
    }
    
    func test_remove_undo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "")
        editor.replace(editor.textRange(from: editor.selectedRange)!, withText: "")
        undoableManager.undo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, prior)
        XCTAssertEqual(editor.selectedRange, NSRange(location: 5, length: 8))
    }
    
    func test_input_undo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 13, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "s")
        editor.insertText("s")
        undoableManager.undo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, prior)
        XCTAssertEqual(editor.selectedRange, NSRange(location: 13, length: 0))
    }
    
    func test_replace_redo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "S")
        editor.replace(editor.textRange(from: editor.selectedRange)!, withText: "S")
        
        undoableManager.undo()
        undoableManager.redo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, "func S")
        XCTAssertEqual(editor.selectedRange, NSRange(location: 6, length: 0))
    }
    
    func test_remove_redo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 5, length: 8)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "")
        editor.replace(editor.textRange(from: editor.selectedRange)!, withText: "")
        undoableManager.undo()
        undoableManager.redo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, "func ")
        XCTAssertEqual(editor.selectedRange, NSRange(location: 5, length: 0))
    }
    
    func test_input_redo() {
        let prior = "func solution"
        editor.text = prior
        editor.selectedRange = NSRange(location: 13, length: 0)
        
        // When
        let systemUpdate = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "s")
        editor.insertText("s")
        undoableManager.undo()
        undoableManager.redo()
        
        // Then
        XCTAssertTrue(systemUpdate)
        XCTAssertEqual(editor.text, "func solutions")
        // XCTAssertEqual(editor.selectedRange, NSRange(location: 14, length: 0))
    }
    
    func visualize(_ string: String) -> String {
        string
            .replacingOccurrences(of: "\n", with: "\\n\n")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
    
    func test_enter_command_execute() {
        let prior = """
func solution() {
}
"""
        editor.text = prior
        editor.selectedRange = NSRange(location: 17, length: 0)
        
        _ = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "\n")
        
        let after = """
func solution() {
\t
}
"""
        XCTAssertEqual(editor.text, after)
    }
    
    func test_enter_command_undo() {
        let prior = """
func solution() {
}
"""
        editor.text = prior
        editor.selectedRange = NSRange(location: 17, length: 0)
        
        _ = manager.commandExecute(shouldChangeTextIn: editor.selectedRange, replacementText: "\n")
        
        
        manager.undoableManager?.undo()
        XCTAssertNotNil(manager.undoableManager)
        XCTAssertEqual(editor.selectedRange, NSRange(location: 17, length: 0))
        XCTAssertEqual(editor.text, prior)
    }
    
}
