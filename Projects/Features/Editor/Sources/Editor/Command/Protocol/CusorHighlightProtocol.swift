
import Foundation


protocol CusorHighlightProtocol: AnyObject {
    func highlight(first fRange: NSRange, second sRange: NSRange)
    func removeHightLight()
}
