@testable import Editor
import XCTest
import CommonUI


final class ButtonCommandExecuteManagerTestCase: XCTestCase {
    private var textView: Editor!
    private var suggestionManager: CompositeSuggestionManager!
    private var suggestion: WordSuggenstion!
    private var suggestionLayout: SuggestionLayout!
    private var undoableManager: UndoableManager!
    private var textCommand: TextInputCommandExcuteManager!
    
    var editorController: EditorController!
    var buttonCommandExecuteManager: ButtonCommandExecuteManager!
    
    override func setUpWithError() throws {
        textView = Editor()
        undoableManager = DefaultUndoableManager(
            editor: textView
        )
        buttonCommandExecuteManager = DefaultButtonCommandExecuteManager(
            editor: textView,
            undoableManager: undoableManager
        )
        suggestion = DefaultWordSuggenstion()
        
        suggestionLayout = SuggestionLayoutManager(editor: textView)
        
        suggestionManager =  DefaultSuggestionManager(
            dependency: .init(
                suggestion: self.suggestion,
                editor: textView,
                suggestionLayout: suggestionLayout,
                suggestionCommand: SuggestionCommand(
                    editor: textView,
                    invoker: undoableManager
                )
            )
        )
        textView.undoableManager = undoableManager
        
        textCommand = DefaultTextInputCommandExcuteManager.init(
            editor: textView,
            undoableManager: self.undoableManager,
            textRangeResolver: TextRangeResolver(editor: textView),
            textInputCommands:
                    SuggestionEnterCommand(suggestionManager: self.suggestionManager),
                    SuggestionGeneratorCommand(suggestionManager: self.suggestionManager),
                    EnterCommand(suggestionLayout: self.suggestionLayout, commandExecutor: textView),
                    AutoRemoveCommand(commandExecutor: textView),
                    AutoPairCharacterCommand(commandExecutor: textView)
        )
        
        editorController = EditorController(dependency: .init(
            textView: textView,
            changeSelecteRange: MockLineNumberView() as? ChangeSelectedRange,
            widthUpdater: MockTextViewWidthUpdate(),
            undoableManager: undoableManager,
            suggestionManager: suggestionManager,
            suggestionLayout: suggestionLayout,
            textInputCommandExcuteManager: textCommand,
            buttonCommandExecuteManager: buttonCommandExecuteManager)
        )
        textView.delegate = editorController
    }
    
    override func tearDownWithError() throws {
        editorController = nil
        buttonCommandExecuteManager = nil
        suggestionManager = nil
        suggestion = nil
        suggestionLayout = nil
        undoableManager = nil
        textCommand = nil
    }
    
    func input_setting() -> Bool {
        let textView = textView!
        
        textView.text = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    f
}
""".replacingOccurrences(of: "    ", with: "\t")
        
        
        textView.selectedRange = NSRange(location: 81, length: 0)
        
        textView.insertText("u")
        
        textView.selectedRange = NSRange(location: 82, length: 0)
        
        let systemUpdate = textView.delegate!.textView?(
            textView,
            shouldChangeTextIn: textView.selectedRange,
            replacementText: "\n"
        )
        
        let after = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with:"\t")
        
        XCTAssertFalse(systemUpdate ?? true)
        XCTAssertEqual(textView.text, after)
        return systemUpdate!
    }
    
    func test_undo_after_suggest_enter__action() {
        _ = input_setting()
        let textView = textView!
        
        let afterUndo = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    fu
}
""".replacingOccurrences(of: "    ", with: "\t")
        
        buttonCommandExecuteManager.undoButtonExecute()
        
        XCTAssertEqual(textView.text, afterUndo)
    }
    
    
    func test_redo_after_suggest_enter__action() {
        _ = input_setting()
        let afterUndo = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.redoButtonExecute()
        
        XCTAssertEqual(textView.text, afterUndo)
    }
    
    func test_deleteLine_action() {
        let textView = textView!
        let base = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 0, length: 0)
        
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        let after = """
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        XCTAssertEqual(textView.text, after)
    }
    
    func test_deleteLine_and_undo_action() {
        let textView = textView!
        let base = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 0, length: 0)
        
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.undoButtonExecute()
        
        XCTAssertEqual(textView.text, base)
    }
    
    func test_deleteLine_and_redo_action() {
        let textView = textView!
        let base = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 0, length: 0)
        
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.deleteLine()
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.undoButtonExecute()
        buttonCommandExecuteManager.redoButtonExecute()
        buttonCommandExecuteManager.redoButtonExecute()
        buttonCommandExecuteManager.redoButtonExecute()
        
        let after = """
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        
        XCTAssertEqual(textView.text, after)
    }
    
    
    func test_move_right_Action() {
        let textView = textView!
        let base = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 0, length: 0)
        
        
        let button = buttonCommandExecuteManager.allCommandButtons.filter {
            $0.accessibilityIdentifier! == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.moveRightButton.string
        }.first!
        
        buttonCommandExecuteManager.moveRightCommand()
        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(textView.selectedRange, NSRange(location: 3, length: 0))
    }
    
    func test_move_left_Action() {
        let textView = textView!
        let base = """
import Foundation

func swift_test_function(_ arr: [Int], _ num: Int) -> Int {
    func
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 3, length: 0)
        
        let button = buttonCommandExecuteManager.allCommandButtons.filter {
            $0.accessibilityIdentifier! == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.moveLeftButton.string
        }.first!
        
        buttonCommandExecuteManager.moveLeftButtonExecute()
        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(textView.selectedRange, NSRange(location: 0, length: 0))
    }
    
    
    func test_move_right_long_Action() {
        let textView = textView!
        let base = """
import Foundation
func solution(_ arr: [Int], _ num: Int) -> Int {
    return 0
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: 0, length: 0)
        
        let expectation = XCTestExpectation(description: "moveRight")
        
        let button = buttonCommandExecuteManager.allCommandButtons.filter {
            $0.accessibilityIdentifier! == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.moveRightButton.string
        }.first!
        
        button.sendActions(for: .touchDown)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            button.sendActions(for: .touchUpOutside)
            XCTAssertEqual(textView.selectedRange, NSRange(location: textView.text.count, length: 0))
            expectation.fulfill()
        })
        
        wait(for: [expectation])
    }
    
    func test_move_left_long_Action() {
        let textView = textView!
        let base = """
import Foundation
func solution(_ arr: [Int], _ num: Int) -> Int {
    return 0
}
""".replacingOccurrences(of: "    ", with: "\t")
        textView.text = base
        textView.selectedRange = NSRange(location: base.count, length: 0)
        
        let expectation = XCTestExpectation(description: "moveLeft")
        
        let button = buttonCommandExecuteManager.allCommandButtons.filter {
            $0.accessibilityIdentifier! == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.moveLeftButton.string
        }.first!
        
        button.sendActions(for: .touchDown)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            button.sendActions(for: .touchUpOutside)
            XCTAssertEqual(textView.selectedRange, NSRange(location: 0, length: 0))
            expectation.fulfill()
        })
        
        wait(for: [expectation])
    }
    
    
    
    
}
