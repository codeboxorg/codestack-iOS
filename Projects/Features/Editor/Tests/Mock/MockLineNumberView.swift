
@testable import CommonUIDemo
@testable import CommonUI
import Foundation


final class MockLineNumberView: ChangeSelectedRange {
    
    func handle() { }
    
    func shouldHandleFocus() -> Bool {
        return true
    }
    
    func removeLayer() { }
}
