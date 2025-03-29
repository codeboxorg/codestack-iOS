import Foundation

enum MatchingCharacter: String, CaseIterable {
    static var allCases: [String] = [
        MatchingCharacter.leftParenthesis.rawValue,
        MatchingCharacter.leftBracket.rawValue,
        MatchingCharacter.leftBrace.rawValue,
        MatchingCharacter.doubleQuote.rawValue,
        MatchingCharacter.singleQuote.rawValue
    ]
    
    case leftParenthesis = "("
    case leftBracket = "["
    case leftBrace = "{"
    case doubleQuote = "\""
    case singleQuote = "'"
    
    var pair: String {
        switch self {
        case .leftParenthesis: return ")"
        case .leftBracket: return "]"
        case .leftBrace: return "}"
        case .doubleQuote: return "\""
        case .singleQuote: return "'"
        }
    }
    
    static func matchingCharacter(_ text: String) -> Self? {
        MatchingCharacter(rawValue: text)
    }
}
