import UIKit
import Global

struct BracketPairCursorCommand: CursorCommand {
    
    weak var editor: UITextView?
    weak var highlightor: CusorHighlightProtocol?
    
    init(editor: UITextView?, highlightor: CusorHighlightProtocol?) {
        self.editor = editor
        self.highlightor = highlightor
    }
    
    var shouldHandle: Bool {
        true
    }
    
    private func findMatch(from index: Int, forward: Bool, in text: NSString) -> Int? {
        let startChar = text.character(at: index)
        guard
            let char = UnicodeScalar(startChar),
            let startType = MatchingCharacter(rawValue: String(char)) else {
            return nil
        }
        
        let pairChar = startType.pair
        var level = 0
        var i = index

        let length = text.length

        while forward ? i < length : i >= 0 {
            let c = text.character(at: i)
            if String(UnicodeScalar(c)!) == String(UnicodeScalar(startChar)!) {
                level += 1
            } else if String(UnicodeScalar(c)!) == pairChar {
                level -= 1
                if level == 0 {
                    return i
                }
            }
            i += forward ? 1 : -1
        }
        return nil
    }
    
    func getPairRange() -> (NSRange, NSRange)? {
        guard let editor else {
            return nil
        }
        
        guard let text = editor.text else {
            return nil
        }
        
        let startIndex = editor.text.startIndex
        let endIndex = editor.text.endIndex
        let cursor = editor.selectedRange.location
        let priorIndex = editor.text.index(editor.text.startIndex, offsetBy: cursor - 1, limitedBy: editor.text.endIndex)
        let afterIndex = editor.text.index(editor.text.startIndex, offsetBy: cursor, limitedBy: editor.text.endIndex)
        
        if let priorIndex, priorIndex >= startIndex, priorIndex < endIndex {
            let priorChar = editor.text[priorIndex]
            if let match = MatchingCharacter(rawValue: String(priorChar)) {
                // 1. priorIndex가 open일 경우
                //    - 1.1 priorIndex를 기준으로 이후 방향으로 matching 되는 close 문자를 찾아야 함
                if match.isOpening {
                    let offset = editor.text.distance(from: editor.text.startIndex, to: priorIndex)
                    let closeIndex = findMatch(from: offset, forward: true, in: text as NSString)
                    if let closeIndex {
                        return (
                            NSRange(location: offset, length: 1),
                            NSRange(location: closeIndex, length: 1)
                        )
                    }
                } else if match.isClosing {
                    // 3. priorIndex가 close일 경우
                    //    - 3.1 priorIndex를 기준으로 이전 방향으로 matching 되는 open 문자를 찾아야 함
                    let offset = editor.text.distance(from: editor.text.startIndex, to: priorIndex)
                    if let openIndex = findMatch(from: offset, forward: false, in: text as NSString) {
                        return (
                            NSRange(location: openIndex, length: 1),
                            NSRange(location: offset, length: 1)
                        )
                    }
                }
            }
        }

        if let afterIndex, afterIndex >= startIndex, afterIndex < endIndex {
            let afterChar = editor.text[afterIndex]
            if let match = MatchingCharacter(rawValue: String(afterChar)) {
                if match.isOpening {
                    // 2. afterIndex가 open일 경우
                    //    - 2.1 afterIndex를 기준으로 이후 방향으로 matching 되는 close 문자를 찾아야 함
                    let offset = editor.text.distance(from: editor.text.startIndex, to: afterIndex)
                    if let closeIndex = findMatch(from: offset, forward: true, in: text as NSString) {
                        return (
                            NSRange(location: offset, length: 1),
                            NSRange(location: closeIndex, length: 1)
                        )
                    }
                } else if match.isClosing {
                    // 4. afterIndex가 close일 경우
                    //    - 4.1 현재 커서 위치를 기준으로 이전 방향으로 matching 되는 open 문자를 찾아야 함
                    let offset = editor.text.distance(from: editor.text.startIndex, to: afterIndex)
                    if let openIndex = findMatch(from: offset, forward: false, in: text as NSString) {
                        return (
                            NSRange(location: openIndex, length: 1),
                            NSRange(location: offset, length: 1)
                        )
                    }
                }
            }
        }
        return nil
    }
    
    func execute() {
        highlightor?.removeHightLight()
        
        guard let open_close: (first: NSRange, second: NSRange)? = getPairRange() else {
            return
        }
        
        if let open_close {
            highlightor?.highlight(first: open_close.first, second: open_close.second)
        }
    }
}
