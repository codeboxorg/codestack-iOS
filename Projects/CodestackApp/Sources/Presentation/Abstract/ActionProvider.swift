
import Foundation

open class _ActionProvider<View: AnyObject> {
    unowned var viewController: View
    
    init(_ container: View) {
        viewController = container
    }
    
    func actionBinding() { }
}
