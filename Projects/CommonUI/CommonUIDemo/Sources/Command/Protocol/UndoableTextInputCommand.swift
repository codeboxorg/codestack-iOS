import UIKit

protocol UndoableTextInputCommand {
    var actionCommandType: ActionCommandType { get }
    func undo(_ editor: UITextView)
    func redo(_ editor: UITextView)
}
