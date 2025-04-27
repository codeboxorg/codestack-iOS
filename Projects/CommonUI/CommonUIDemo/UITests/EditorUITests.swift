import XCTest


final class EditorUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_typing_auto_pair() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        // 정확히 중앙을 tap
        let center = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        
        // 키보드 기다리기
        let keyboard = app.keyboards.element
        XCTAssertTrue(keyboard.waitForExistence(timeout: 2))
        
        
        if let currentText = textView.value as? String {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            textView.typeText(deleteSequence)
        }
        
        textView.typeText("Hello")
        textView.typeText("(")
        
        XCTAssertEqual(textView.value as? String, "Hello()")
    }
    
    func test_typing_auto_pair2() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        // 정확히 중앙을 tap
        let center = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        
        // 키보드 기다리기
        let keyboard = app.keyboards.element
        XCTAssertTrue(keyboard.waitForExistence(timeout: 2))
        
        
        if let currentText = textView.value as? String {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            textView.typeText(deleteSequence)
        }
        
        textView.typeText("func solution")
        textView.typeText("(")
        let target = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))
        target.tap()

        textView.typeText(" ")
        textView.typeText("{")
        textView.typeText("\n")
        
        let result = """
func solution() {
    
}
"""
        XCTAssertEqual((textView.value as! String).replacingOccurrences(of: "\t", with: "    "), result)
    }
    
    func test_suggestion_enter() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        // 정확히 중앙을 tap
        let center = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        
        // 키보드 기다리기
        let keyboard = app.keyboards.element
        XCTAssertTrue(keyboard.waitForExistence(timeout: 2))
        
        
        if let currentText = textView.value as? String {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            textView.typeText(deleteSequence)
        }
        
        textView.typeText("func sol")
        textView.typeText("\n")
        
        let result = """
func solution
"""
        XCTAssertEqual((textView.value as! String).replacingOccurrences(of: "\t", with: "    "), result)
    }
    
    
    func test_undo_redo() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        // 정확히 중앙을 tap
        let center = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        
        if let currentText = textView.value as? String {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            textView.typeText(deleteSequence)
        }
        
        textView.typeText("""
func solution value Int append
""")
        let button = app.buttons["undoButton"]
        
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        
        XCTAssertEqual((textView.value as! String), "func solution value Int ")
    }
    
    func test_utf16_undo_redo() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        
        let center = textView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.tap()
        
        if let currentText = textView.value as? String {
            let deleteSequence = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentText.count)
            textView.typeText(deleteSequence)
        }
        
        let origin = "func sol"
        textView.typeText(origin)
        textView.typeText("\n")
        textView.typeText("(")
        
        let moveRight = app.buttons["moveRightButton"]
        moveRight.tap()
        textView.typeText(" {")
        textView.typeText("\n")
        textView.typeText("p")
        textView.typeText("\n")
        
        let button = app.buttons["undoButton"]
        button.tap()
        button.tap()
        button.tap()
        
        let redoButton = app.buttons["redoButton"]
        redoButton.tap()
        redoButton.tap()
        redoButton.tap()
        
        let result = """
func solution() {
    prefix
}
""".replacingOccurrences(of: "    ", with: "\t")
        
        XCTAssertEqual((textView.value as! String), result)
    }
}
