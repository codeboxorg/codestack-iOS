
import UIKit

protocol EditorControl: AnyObject {
    var moveTimer: Timer? { get set }
    var editor: UITextView? { get }
    func moveLeftTimerTouchExecute()
    func moveRightTimerTouchExecute()
}


