import UIKit

protocol EnterCommandExecutor: AnyObject {
    func enterCommandExecute(range: NSRange, text: String) -> Bool
}
