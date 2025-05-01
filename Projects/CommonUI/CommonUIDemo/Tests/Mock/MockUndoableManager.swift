

@testable import CommonUIDemo



final class MockUpdateUndoRedoButtonStateDelegate: UpdateUndoRedoButtonStateDelegate {
    func updateUndoRedoButtonState() {
        
    }
}

final class MockUndoableManager: UndoableManager {
    var updateUndoRedoButtonStateDelegate: (any CommonUIDemo.UpdateUndoRedoButtonStateDelegate)?
    
    var isUndoable: Bool {
        false
    }
    
    var isRedoable: Bool {
        false
    }
    
    func push(_ command: any CommonUIDemo.UndoableTextInputCommand) {
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
