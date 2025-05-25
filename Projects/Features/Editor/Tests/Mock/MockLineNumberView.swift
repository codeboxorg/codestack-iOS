
@testable import Editor
import Foundation
import CommonUI


final class MockLineNumberView: ChangeSelectedRange {
    
    func handle() { }
    
    func shouldHandleFocus() -> Bool {
        return true
    }
    
    func removeLayer() { }
}
