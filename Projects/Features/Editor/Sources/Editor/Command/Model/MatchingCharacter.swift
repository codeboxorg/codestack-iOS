import Foundation

enum MatchingCharacter: String, CaseIterable {
    static var allCases: [String] = [
        MatchingCharacter.leftParenthesis.rawValue,
        MatchingCharacter.leftBracket.rawValue,
        MatchingCharacter.leftBrace.rawValue,
        MatchingCharacter.doubleQuote.rawValue,
        MatchingCharacter.singleQuote.rawValue,
        MatchingCharacter.rightBrace.rawValue,
        MatchingCharacter.rightBracket.rawValue,
        MatchingCharacter.rightParenthesis.rawValue
    ]
    
    case leftParenthesis = "("
    case leftBracket = "["
    case leftBrace = "{"
    case doubleQuote = "\""
    case singleQuote = "'"
    case rightParenthesis = ")"
    case rightBracket = "]"
    case rightBrace = "}"
    
    var pair: String {
        switch self {
        case .leftParenthesis:  return Self.rightParenthesis.rawValue
        case .leftBracket:      return Self.rightBracket.rawValue
        case .leftBrace:        return Self.rightBrace.rawValue
        case .doubleQuote:      return Self.doubleQuote.rawValue
        case .singleQuote:      return Self.singleQuote.rawValue
        case .rightParenthesis: return Self.leftParenthesis.rawValue
        case .rightBracket:     return Self.leftBracket.rawValue
        case .rightBrace:       return Self.leftBrace.rawValue
        }
    }
    
    var isOpening: Bool {
        switch self {
        case .leftParenthesis, .leftBracket, .leftBrace, .doubleQuote, .singleQuote:
            return true
        default:
            return false
        }
    }

    var isClosing: Bool {
        switch self {
        case .rightParenthesis, .rightBracket, .rightBrace, .doubleQuote, .singleQuote:
            return true
        default:
            return false
        }
        
    }
    
    static func matchingCharacter(_ text: String) -> Self? {
        MatchingCharacter(rawValue: text)
    }
    
    static func isBracketPair(prev: Character, next: Character) -> Bool {
        switch (prev, next) {
        case ("{", "}"), ("[", "]"), ("(", ")"): return true
        default: return false
        }
    }
    
    static func removalPair(prev: Character, next: Character) -> Bool {
        switch (prev, next) {
        case ("{", "}"), ("[", "]"), ("(", ")"), ("\"", "\""), ("'", "'"): return true
        default: return false
        }
    }
}
