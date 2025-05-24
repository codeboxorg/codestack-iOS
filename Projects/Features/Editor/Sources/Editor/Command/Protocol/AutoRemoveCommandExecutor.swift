import UIKit

protocol AutoRemoveCommandExecutor: AnyObject {
    func autoRemoveCommandExecute(range: NSRange, text: String) -> Bool
}

