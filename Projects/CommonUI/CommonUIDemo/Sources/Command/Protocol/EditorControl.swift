
import UIKit

protocol EditorControl: AnyObject {
    var moveTimer: Timer? { get set }
    var textView: UITextView? { get set }
}
