





import UIKit



public final class CustomSegmentControl: BaseView {
    
    private var segmentControl: UISegmentedControl = {
        let titles = ["0","1"]
        let segmentControl = UISegmentedControl(items: titles)
        segmentControl.tintColor = UIColor.white
        segmentControl.backgroundColor = UIColor.blue
        segmentControl.selectedSegmentIndex = 0
        segmentControl.setImage(UIImage(systemName: "rectangle"), forSegmentAt: 0)
        segmentControl.setImage(UIImage(systemName: "list.bullet"), forSegmentAt: 1)
        for index in 0...titles.count - 1 {
            segmentControl.setWidth(50, forSegmentAt: index)
        }
        return segmentControl
    }()
    
    public override func addAutoLayout() {
        
    }
    
    public override func applyAttributes() {
        
    }
    
}




