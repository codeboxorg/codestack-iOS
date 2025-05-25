

@testable import Editor

final class MockUpdateUndoRedoButtonStateDelegate: UpdateUndoRedoButtonStateDelegate {
    func updateUndoRedoButtonState() {
        
    }
}

final class MockUndoableManager: UndoableManager {
    var updateUndoRedoButtonStateDelegate: (any UpdateUndoRedoButtonStateDelegate)?
    
    var isUndoable: Bool {
        false
    }
    
    var isRedoable: Bool {
        false
    }
    
    func push(_ command: any UndoableTextInputCommand) {
        
    }
    
    func undo() {
        
    }
    
    func redo() {
        
    }
}
