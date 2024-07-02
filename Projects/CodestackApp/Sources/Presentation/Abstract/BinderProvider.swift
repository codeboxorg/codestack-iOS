
import Foundation

open class _BinderProvider<View: AnyObject> {
    unowned var viewController: View
    
    init(_ container: View) {
        viewController = container
    }
}
