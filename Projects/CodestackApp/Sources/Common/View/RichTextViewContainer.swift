//
//
//
//
//
//
//import UIKit
//import SwiftUI
//import CommonUI
//
//final class RichTextViewContainer: BaseView {
//    
//    private(set) var postingTitle = PostingTitleView()
//    
//    private(set) lazy var tagContainer: TagContainer = {
//        let container = TagContainer(frame: self.view.frame, spacing: 10)
//        return container
//    }()
//    
//    private(set) var richTextSwiftUIView: some View {
//        RichTextSwiftUIView(htmlString, { [weak self] height in
//           self?.layoutConstraintHeight?.constant = height
//       })
//    }
//    
//    private var layoutConstraintHeight: NSLayoutConstraint?
//    
//    override func applyAttributes() {
//        
//    }
//    
//    override func addAutoLayout() {
//        contentView.addSubview(postingTitle)
//        contentView.addSubview(tagContainer)
//        contentView.addSubview(containerView)
//        
//        contentView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
//            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
//            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
//            make.bottom.equalTo(view.snp.bottom).offset(80)
//            make.height.equalTo(400).priority(.low)
//        }
//        
//        postingTitle.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.trailing.equalToSuperview()
//            make.width.equalTo(Position.screenWidth)
//            make.height.equalTo(200).priority(.low)
//        }
//        
//        tagContainer.snp.makeConstraints { make in
//            make.top.equalTo(postingTitle.snp.bottom).offset(5)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(150)
//        }
//        
//        containerView.snp.makeConstraints { make in
//            make.top.equalTo(tagContainer.snp.bottom).offset(5)
//            make.leading.trailing.equalToSuperview()
//            make.width.equalTo(Position.screenWidth)
//            make.height.equalTo(500).priority(.low)
//            make.bottom.equalToSuperview()
//        }
//    }
//}
