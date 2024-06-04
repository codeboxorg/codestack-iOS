import UIKit


public final class MockViewController: UIViewController {
    
    public func set(color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
