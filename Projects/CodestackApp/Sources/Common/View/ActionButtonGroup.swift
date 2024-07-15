

import UIKit
//struct ViewTypeActionButton {
//    lazy var makeRightTopButton: (ViewType) -> UIBarButtonItem
//    =
//    { [weak self] viewType in
//        let button =  UIBarButtonItem(image: UIImage(systemName: "gearshape"))
//        var actionType: [UIAction]
//        let action: (ActionType) -> UIAction = { actionType in
//            UIAction { action in
//                self?.viewmodel.sendActionWrapper = actionType
//            }
//        }
//        switch viewType {
//        case .myPostingTemp:
//            actionType = [
//                ActionType.publish,
//                ActionType.delete,
//                ActionType.setting
//            ].map { type in
//                action(type)
//            }
//        case .myPosting:
//            actionType = [
//                ActionType.fix,
//                ActionType.setting
//            ].map { type in
//                action(type)
//            }
//        case .posting:
//            actionType = [
//                ActionType.temporary ,
//                ActionType.publish,
//                ActionType.setting
//            ].map { type in
//                action(type)
//            }
//        case .preview:
//            actionType = [
//                ActionType.temporary ,
//                ActionType.publish,
//                ActionType.setting
//            ].map { type in
//                action(type)
//            }
//        }
//
//        button.menu = UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: actionType)
//        return button
//    }
//}

// MARK: preview 일 경우 -> 저장 OR 출간
// MARK: myPosting일 경우 -> 수정하기
// MARK: other -> 댓글 OR 설정

// MARK: 상속 OR Composition OR Enum, OR Function

public protocol ActionButtonGroup {
    init()
    
    /// UIMenu를 팝업하는 Action Button Item 메서드
    /// - Parameter action: Closure Action
    /// - Returns: UIBarButton Item
    func makeRightBarButtonItem(_ action: @escaping (UIAction) -> Void) -> UIBarButtonItem
}

public extension ActionButtonGroup {
    
    /// 프로토콜 내부에서 쓰는 메서드, Protocol을 conform하는 인스턴스 에서 사용
    /// - Parameters:
    ///   - type: Action Type
    ///   - action: UIAction
    /// - Returns: UIBarbuttonItem
    func makeBarButtonItem(_ type: [String], _ action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        let button =  UIBarButtonItem(image: UIImage(systemName: "gearshape"))
        var actionType: [UIAction] = []
        
        let rightActionClosure: (String) -> UIAction = { actionTitle in
            UIAction(title: actionTitle, handler: action)
        }
        
        actionType = type.map { type in
            rightActionClosure(type)
        }
        button.menu = UIMenu(title: "Hello", image: nil, identifier: nil, options: .destructive, children: actionType)
        return button
    }
}


struct MyPostingActionButtonGroup: ActionButtonGroup {
    func makeRightBarButtonItem(_ action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        makeBarButtonItem([ActionType.delete].map(\.string), action)
    }
}

struct OtherPostingActionButtonGroup: ActionButtonGroup {
    func makeRightBarButtonItem(_ action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        makeBarButtonItem([ActionType.setting, ActionType.reported].map(\.string), action)
    }
}

struct MyTempPostingActionButtonGroup: ActionButtonGroup {
    func makeRightBarButtonItem(_ action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        makeBarButtonItem([ActionType.setting, ActionType.delete].map(\.string), action)
    }
}

struct PreviewsActionButtonGroup: ActionButtonGroup {
    func makeRightBarButtonItem(_ action: @escaping (UIAction) -> Void) -> UIBarButtonItem {
        makeBarButtonItem([ActionType.temporary, ActionType.publish, ActionType.delete].map(\.string), action)
    }
}
