import UIKit
import Global

protocol SuggestionManager: AnyObject {
    func suggestionLayoutGenerate()
    func initSuggestion()
    func findPriorWord() -> String?
    func removeSuggestionView()
    func excuteWhenCusorPositionChanged()
    func insertCurrentFocusingSuggestionWord()
    
    func input(for text: String)
    func remove(for text: String)
    
    var isSuggestionFocusingState: Bool { get }
}

final class DefaultSuggestionManager: SuggestionManager {
    
    struct Dependency {
        var suggestion: WordSuggenstion
        var editor: UITextView?
        var layoutManager: SuggestionLayout
        var invoker: CommandInvoker
    }
    
    private var suggestionCommand: SuggestionCommand
    private let suggestion: WordSuggenstion
    private weak var editor: UITextView?
    private var layout: SuggestionLayout?
    private var currentFocusingItem: String = ""
    
    var isSuggestionFocusingState: Bool {
        guard let layout else {
            return false
        }
        if case .focusing = layout.state {
            return true
        } else {
            return false
        }
    }
    
    init(dependency: Dependency) {
        self.suggestion = dependency.suggestion
        self.editor = dependency.editor
        self.layout = dependency.layoutManager
        self.suggestionCommand = SuggestionCommand(
            editor: dependency.editor,
            invoker: dependency.invoker
        )
    }
    
    func initSuggestion() {
        guard let editor = editor else {
            return
        }
        let swiftString = "Int,Int8,Int16,Int32,Int64,UInt,UInt8,UInt16,UInt32,UInt64,Float,Double,Bool,String,Character,Array,Dictionary,Set,Any,AnyObject,Never,Optional,Error,if,else,guard,switch,case,default,for,while,repeating,in,break,continue,return,throw,try,catch,defer,do,let,var,func,typealias,struct,class,enum,protocol,extension,init,deinit,subscript,public,private,fileprivate,internal,open,static,final,override,convenience,lazy,mutating,nonmutating,weak,unowned,strong,self,super,as,is,await,async,throws,inout,some,any,where,associatedtype,print,debugPrint,map,flatMap,compactMap,filter,reduce,forEach,sorted,contains,first,last,count,isEmpty,append,remove,insert,dropFirst,dropLast,split,joined,prefix,suffix,index,indices,hasPrefix,hasSuffix,uppercased,lowercased,trimmingCharacters,random,shuffled".split(separator: ",").map { String($0) }.joined(separator: " ")
        
        let protocolKeywords = "Collection,BidirectionalCollection,MutableCollection,Sequence,IteratorProtocol,CustomStringConvertible,CustomDebugStringConvertible,CustomReflectable,Equatable,Comparable,Hashable,Codable,CaseIterable"
        
        suggestion.input(for: protocolKeywords)
        suggestion.input(for: swiftString)
        suggestion.input(for: editor.text)
    }
    
    func removeSuggestionView() {
        layout?.state = .none
    }
    
    /// Cusor Command에서 이 함수 호출
    /// Cusor의 위치 변화에 따라서 Suggestion 상태 변경이 필요할 때
    func excuteWhenCusorPositionChanged() {
        if isSuggestionFocusingState {
            suggestionLayoutGenerate()
        }
    }
    
    // TODO: 수정 필요
    /// 1. HandleInput 에서 현재 커서가 단어의 끝에 있을 경우에만 input을 적용 ( cursor가 단어의 중간에 있을때는 미적용) (완료)
    /// 2. Debouncing Thorottling 적용
    func suggestionLayoutGenerate() {
        guard let layout = layout else {
            return
        }
        
        guard let (word, cursorPosition) = suggestionCommand.findPriorCusorWords() else {
            return
        }
        
        guard suggestionCommand.isRightPosition(cursorPosition: cursorPosition) else {
            layout.state = .none
            return
        }

        let suggestedWords: [SuggestionWord] = suggestion.suggest(for: word)

        if suggestionCommand.contains(other: suggestedWords, word: word)
        {
            layout.state = .none
            return
        }

        if suggestedWords.isEmpty {
            layout.state = .none
            return
        }
        
        layout.state = .focusing(suggestedWords.map(\.word)) { [weak self] word in
            guard let self else { return }
            self.suggestionCommand.insert(using: word)
            layout.state = .none
        } gestureAction: { [weak self] word in
            guard let self else { return }
            currentFocusingItem = word
        }
    }
    
    func findPriorWord() -> String? {
        suggestionCommand.findPriorWord()
    }
    
    func insertCurrentFocusingSuggestionWord() {
        suggestionCommand.insert(using: currentFocusingItem)
        layout?.state = .none
    }
    
    func input(for text: String) {
        suggestion.input(for: text)
    }
    
    func remove(for text: String) {
        suggestion.remove(for: text)
    }
}


internal struct SuggestionCommand {
    weak var editor: UITextView!
    weak var invoker: UndoableManager?
    
    init(editor: UITextView?, invoker: UndoableManager?) {
        self.editor = editor
        self.invoker = invoker
    }
    
    func findWordStartPosition() -> UITextPosition? {
        guard let editor, let range = editor.selectedTextRange else {
            return nil
        }
        var current = range.start
        while let prev = editor.position(from: current, offset: -1),
              let textRange = editor.textRange(from: prev, to: current),
              let char = editor.text(in: textRange),
              char.range(of: "[a-zA-Z0-9_]", options: .regularExpression) != nil {
            current = prev
        }
        return current
    }

    func findPriorWord() -> String? {
        guard let editor, let start = findWordStartPosition(),
              let end = editor.selectedTextRange?.start,
              let textRange = editor.textRange(from: start, to: end),
              let word = editor.text(in: textRange) else {
            return nil
        }
        return word
    }
    
    func findPriorCusorWords() -> (word: String, position: UITextPosition)? {
        guard let word = findPriorWord(),
              let position = findWordStartPosition() else {
            return nil
        }
        
        return (word, position)
    }
    
    func contains(other suggestedWords: [SuggestionWord], word: String) -> Bool {
        suggestedWords.contains(where: { $0.word == word }) &&
        !suggestedWords.contains(where: { $0.word.hasPrefix(word) && $0.word != word })
    }
    
    /// 커서가 단어의 중간이면 suggestion 미표시
    func isRightPosition(cursorPosition: UITextPosition) -> Bool {
        if let nextCharPosition = editor.position(from: cursorPosition, offset: 0),
           let nextCharPosition2 = editor.position(from: nextCharPosition, offset: 1),
           let textRange = editor.textRange(from: cursorPosition, to: nextCharPosition2),
           let nextChar = editor.text(in: textRange),
           nextChar.range(of: "[a-zA-Z0-9_]", options: .regularExpression) != nil {
            return true
        } else {
            return false
        }
    }
    
    func insert(using word: String) {
        guard let (_, position) = findPriorCusorWords(),
              let editor = editor,
              let range = editor.textRange(
                from: position, to: editor.selectedTextRange!.start
              )
        else {
            return
        }
        
        let startOffset = editor.offset(from: editor.beginningOfDocument, to: range.start)
        let undoRange = editor.textRange(from: editor.beginningOfDocument,offset: startOffset, length: word.count)
        
        let undoCommand = UndoSnapshotCommand(
            undoRange: undoRange,
            redoRange: range,
            insertedText: word,
            replacedText: "",
            selectedTextRange: nil,
            oldSelectedTextRange: nil
        )
        
        editor.replace(range, withText: word)
        
        invoker?.push(undoCommand)
    }
}
