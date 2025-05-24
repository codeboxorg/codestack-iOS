import UIKit

protocol AutoPairCommandExecutor: AnyObject {
    func autoPairExecute(range: NSRange, text: String) -> Bool
}

