@testable import Editor
import XCTest


final class SuggestionMangerTest: XCTestCase {
    
    var suggestionManager: CompositeSuggestionManager!
    var suggestionCommand: SuggestionCommand!
    var dependency: DefaultSuggestionManager.Dependency!
    
    override func setUp() {
        let textView = UITextView()
        suggestionCommand = SuggestionCommand(
            editor: textView,
            invoker: MockUndoableManager()
        )
        dependency = .init(
            suggestion: DefaultWordSuggenstion(),
            editor: textView,
            suggestionLayout: SuggestionLayoutManager(editor: textView),
            suggestionCommand: suggestionCommand
        )
        suggestionManager = DefaultSuggestionManager(
            dependency: dependency
        )
    }
    
    override func tearDown() {
        dependency = nil
        suggestionCommand = nil
        suggestionManager = nil
    }
    
    // 1. getWord -> (Word, cusorPosition) command.findPriorCusorWords()    2개
    // 2. isRightPosition -> Bool          command.isRightPosition()        2개
    // 3. execute Suggest function   -> [SuggestionWord]                    2개
    // 4. command.contains() 같은 word 이외의 값이 있는지 확인                     2개
    // 5. 값이 비어있는지 확인                                                   2개
    // 6. layout state focusing으로 변경                                      1개
    func test_suggestion_findPriorCusorWords_커서의_왼쪽방향의_단어를_가져오기_성공() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        let positionCount = editor.text.count - 2
        
        // When
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let tuple = suggestionCommand.findPriorCusorWords()
        
        
        // Then
        XCTAssertNotNil(tuple)
        
        let (word, position) = tuple!
        let result = "solution"
        
        XCTAssertEqual(word, "solution")
        
        let nsRange = editor.nsRange(from: editor.textRange(from: position, to: position)!)
        let rightposition = NSRange(location: positionCount - result.count, length: 0)
        XCTAssertEqual(nsRange, rightposition)
        
        let substring = (editor.text as NSString).substring(with: NSRange(location: rightposition.location, length: result.count))
        XCTAssertEqual(substring, "solution")
    }
    
    func test_suggestion_findPriorCusorWords_커서의_왼쪽방향의_단어를_가져오기_실패_1() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        
        // When
        editor.selectedTextRange = nil
        let tuple = suggestionCommand.findPriorCusorWords()
        
        
        // Then
        // Range 를 선택 안했을 경우 nil 반환
        XCTAssertNil(tuple)
    }
    
    func test_suggestion_findPriorCusorWords_커서의_왼쪽방향의_단어를_가져오기_실패_2() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        let positionCount = editor.text.count - 1
        
        // When
        // soltuion({positioning})
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let tuple = suggestionCommand.findPriorCusorWords()
        
        
        // Then
        // Range 를 선택하고 왼쪽 단어는
        XCTAssertNotNil(tuple)
        XCTAssertTrue(tuple!.word.isEmpty)
        let textRange = editor.textRange(from: tuple!.position, to: tuple!.position)
        let nsRange = editor.nsRange(from: textRange!)
        XCTAssertEqual(nsRange, NSRange(location: positionCount, length: 0))
    }
    
    
    func test_suggestion_isRightPosition_커서가_올바른_Position에_있는지_확인_False() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        let positionCount = editor.text.count - 3
        
        // When
        // soltuio{cursor}n()
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let position = editor.position(from: editor.beginningOfDocument, offset: editor.selectedRange.location)
        let isRightPosition = suggestionCommand.isRightPosition(cursorPosition: position!)
        
        XCTAssertEqual(isRightPosition, false)
        XCTAssertEqual(dependency.suggestionLayout.state, .none)
    }
    
    func test_suggestion_isRightPosition_커서가_올바른_Position에_있는지_확인_True() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        let positionCount = editor.text.count - 2
        
        // When
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let position = editor.position(from: editor.beginningOfDocument, offset: editor.selectedRange.location)
        let isRightPosition = suggestionCommand.isRightPosition(cursorPosition: position!)
        
        
        // Then
        XCTAssertEqual(isRightPosition, true)
    }
    
    func test_suggestion_suggest() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        suggestionManager.initSuggestion()
        editor.text.append("sol")
        let positionCount = editor.text.count
        
        // When
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let (word, _) = suggestionCommand.findPriorCusorWords()!
        let suggestions = dependency.suggestion.suggest(for: word)
        
        // Then
        XCTAssertEqual(suggestions, [SuggestionWord(word: "solution", count: 1)])
    }
    
    
    /// True 일 경우 layout State none
    func test_suggestion_contains_True() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        // When
        suggestionManager.initSuggestion()
        editor.text.append("solution")
        let positionCount = editor.text.count
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let (word, _) = suggestionCommand.findPriorCusorWords()!
        let suggestions = dependency.suggestion.suggest(for: word)
        
        // Then
        let bool = suggestionCommand.contains(other: suggestions, word: word)
        
        XCTAssertTrue(bool)
    }
    
    func test_suggestion_contains_False() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        // When
        suggestionManager.initSuggestion()
        editor.text.append("solution")
        let positionCount = editor.text.count
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        let (word, _) = suggestionCommand.findPriorCusorWords()!
        let suggestions = dependency.suggestion.suggest(for: word)
        
        // Then
        let bool = suggestionCommand.contains(other: suggestions, word: word)
        
        XCTAssertTrue(bool)
    }
    
    func test_suggestion_layout_state_focusing() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        // When
        suggestionManager.initSuggestion()
        editor.text.append("sol")
        let positionCount = editor.text.count
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        
        suggestionManager.suggestionLayoutGenerate()
        
        // Then
        XCTAssertEqual(
            dependency.suggestionLayout.state,
            .focusing([], selectAction: { _ in }, gestureAction: { _ in })
        )
    }
    
    func test_suggestion_layout_state_none_focusing() {
        // Given
        let editor = dependency.editor!
        editor.text = """
import Foundation
solution()
"""
        // When
        suggestionManager.initSuggestion()
        editor.text.append("sol")
        let positionCount = editor.text.count - 1
        editor.selectedRange = NSRange(location: positionCount, length: 0)
        
        suggestionManager.suggestionLayoutGenerate()
        
        // Then
        XCTAssertEqual(
            dependency.suggestionLayout.state,
            .none
        )
    }
}
