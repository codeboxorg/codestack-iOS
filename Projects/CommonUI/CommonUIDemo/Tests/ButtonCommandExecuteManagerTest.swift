@testable import CommonUIDemo
@testable import CommonUI
import XCTest


final class ButtonCommandExecuteManagerTestCase: XCTestCase {
    var editorController: EditorController!
    var buttonCommandExecuteManager: ButtonCommandExecuteManager!
    
    override func setUpWithError() throws {
        let textView = UITextView()
        
        let undoableManager = DefaultUndoableManager(
            editor: textView
        )
        
        buttonCommandExecuteManager = DefaultButtonCommandExecuteManager(
            editor: textView,
            undoableManager: undoableManager
        )
        
        let dependency = EditorController.Dependency(
            textView: textView,
            lineNumberView: MockLineNumberView(),
            buttonCommandExecuteManager: buttonCommandExecuteManager,
            undoableManager: undoableManager
        )
        
        editorController = EditorController(
            dependency: dependency
        )
        
        textView.delegate = editorController
    }
    
    override func tearDownWithError() throws {
        editorController = nil
        buttonCommandExecuteManager = nil
    }
    
    func input_setting() -> Bool? {
        let textView = editorController.textView!
        
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
""".replacingOccurrences(of: "    ", with: "\t")
        
        XCTAssertFalse(systemUpdate ?? true)
        XCTAssertEqual(editorController.textView!.text, after)
        return systemUpdate
    }

    
    
    func test_undo_after_suggest_enter__action() {
        _ = input_setting()
        let textView = editorController.textView!
        
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
        
        XCTAssertEqual(editorController.textView!.text, afterUndo)
    }
    
    func test_deleteLine_action() {
        let textView = editorController.textView!
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
        XCTAssertEqual(editorController.textView!.text, after)
    }
    
    func test_deleteLine_and_undo_action() {
        let textView = editorController.textView!
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
        
        XCTAssertEqual(editorController.textView!.text, base)
    }
    
    func test_deleteLine_and_redo_action() {
        let textView = editorController.textView!
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
        
        XCTAssertEqual(editorController.textView!.text, after)
    }
}
