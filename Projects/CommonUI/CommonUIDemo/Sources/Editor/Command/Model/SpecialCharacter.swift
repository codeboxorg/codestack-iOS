import Foundation

enum SpecialLigature: String, CaseIterable {
    case arrow = "->"
    case notEqual = "!="
    case equalEqual = "=="
    case greaterEqual = ">="
    case lessEqual = "<="
    case plusEqual = "+="
    case minusEqual = "-="
    case multiplyEqual = "*="
    case divideEqual = "/="
    case percentEqual = "%="
    case andAnd = "&&"
    case orOr = "||"
    case enter = "\n"
    case back = "x"
    case space = " "
    
    static var all: [SpecialLigature] {
        return Array(Self.allCases)
    }
    
    static var strings: [String] {
        return all.map { $0.rawValue }
    }
}
