import Foundation
import Global

protocol WordSuggenstion: AnyObject {
    func input(for text: String)
    func remove(for text: String)
    func suggest(for prefix: String) -> [SuggestionWord]
}

struct SuggestionWord: Equatable {
    let word: String
    let count: Int
}

final class DefaultWordSuggenstion: WordSuggenstion {
    private var wordCount = [String: Int]()
    
    func input(for text: String) {
        let wordList = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
        for word in wordList where word.startIndex != word.endIndex &&
            word.rangeOfCharacter(from: .letters) != nil &&
            word.index(word.startIndex, offsetBy: 2, limitedBy: word.endIndex) != nil {
                wordCount[word, default: 0] += 1
        }
    }
    
    func remove(for text: String) {
        let wordList = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
        for word in wordList where word.startIndex != word.endIndex &&
            word.rangeOfCharacter(from: .letters) != nil &&
            word.index(word.startIndex, offsetBy: 2, limitedBy: word.endIndex) != nil {
            if let count = wordCount[word] {
                if count > 1 {
                    wordCount[word] = count - 1
                } else {
                    wordCount.removeValue(forKey: word)
                }
            }
        }
    }
    
    func suggest(for prefix: String) -> [SuggestionWord] {
        if prefix.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            prefix.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return []
        }

        return wordCount
            .filter { $0.key.lowercased().hasPrefix(prefix.lowercased()) }
            .map { SuggestionWord(word: $0.key, count: $0.value) }
            .sorted {
                if $0.count == $1.count {
                    return $0.word < $1.word
                }
                return $0.count > $1.count
            }
    }
}
