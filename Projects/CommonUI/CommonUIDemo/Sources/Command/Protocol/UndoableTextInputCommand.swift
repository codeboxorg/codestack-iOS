import UIKit

protocol UndoableTextInputCommand {
    func undo(_ editor: UITextView)
    func redo(_ editor: UITextView)
}
