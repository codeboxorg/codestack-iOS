import UIKit
import CommonUI

struct FocusCursorCommand: CursorCommand {
    weak var lineNumberView: ChangeSelectedRange?
    
    init(line: ChangeSelectedRange?) {
        self.lineNumberView = line
    }
    
    var shouldHandle: Bool {
        lineNumberView?.shouldHandleFocus() ?? false
    }

    func execute() {
        lineNumberView?.handle()
    }
}
