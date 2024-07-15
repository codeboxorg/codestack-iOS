


import SwiftUI
import CommonUI
import UIKit

final class TagsViewController: BaseViewController {
    
    let textField: InsetTextField = {
        let field = InsetTextField()
        field.placeholder = "태그를 입력해주세요"
        return field
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func applyAttributes() {
        
    }
    
    override func binding() {
        
    }
}


class SampleVC: UIViewController {
    
    let tagView = TagSeletedView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagView.layer.borderColor = UIColor.black.cgColor
        tagView.layer.borderWidth = 1
        
        tagView.hideButton
            .addAction(
                UIAction(handler: { [weak tagView] v in
                    tagView?.hideButton.hideFlag.toggle()
                    guard let val = tagView?.hideButton.hideFlag else {
                        return
                    }
                    tagView?.remakeTagHeightWhenTags(isHide: val)
                }),
                for: .touchUpInside
            )
        
        tagView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tagView)
    }
}

@available(iOS 17.0, *)
#Preview {
    
    @State var height: CGFloat = 100
    
    let view = TagSeletedView()
    view.layer.borderColor = UIColor.black.cgColor
    view.layer.borderWidth = 1
    
    view.tagAddButton
        .addAction(
            UIAction(handler: {[weak view] v in
                // view?.insert(tag: "안녕하세요\((0...100).randomElement()!)")
            }),
            for: .touchUpInside
        )
    
    view.hideButton
        .addAction(
            UIAction(handler: { [weak view] v in
                view?.hideButton.hideFlag.toggle()
                guard let val = view?.hideButton.hideFlag else {
                    return
                }
                view?.remakeTagHeightWhenTags(isHide: val)
                // view?.tagSeletedViewAnimation(tag: val)
            }),
            for: .touchUpInside
        )
    let vc = SampleVC()
    return vc.showPreview()
//    return VStack {
//        view.showPreview()
//    }.onChange(of: height, perform: {
//        print("height \($0)")
//    })
}
// TagSelectedView
