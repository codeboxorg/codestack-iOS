
import Foundation

#if canImport(SwiftUI)
import SwiftUI
import UIKit

public enum DeviceType {
    case iPhoneSE2
    case iPhone8
    case iPhone15Pro
    case iPhone12ProMax
    case iPhone12Mini

    public func name() -> String {
        switch self {
        case .iPhoneSE2:
            return "iPhone SE"
        case .iPhone8:
            return "iPhone 8"
        case .iPhone15Pro:
            return "iPhone 15 Pro"
        case .iPhone12ProMax:
            return "iPhone 12 Pro Max"
        case .iPhone12Mini:
            return "iPhone 12 mini"
        }
    }
}

public struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View

    public init(_ builder: @escaping () -> View) {
        view = builder()
    }

    public func makeUIView(context: Context) -> UIView {
        return view
    }

    public func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}


public extension UIView {
    struct Preview: UIViewRepresentable {
        public typealias UIViewType = UIView

        let view: UIView

        public func makeUIView(context: Context) -> UIView {
            return view
        }

        public func updateUIView(_ uiView: UIView, context: Context) {
        }
    }

    func showPreview(_ deviceType: DeviceType = .iPhone12Mini) -> some View {
        Preview(view: self).previewDevice(PreviewDevice(rawValue: deviceType.name()))
    }
}

public extension UIViewController {

    struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        public func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func showPreview(_ deviceType: DeviceType = .iPhone12Mini) -> some View {
        Preview(viewController: self)
            .previewDevice(PreviewDevice(rawValue: deviceType.name()))
    }
    
    
    struct TabPreview: UIViewControllerRepresentable {
        let viewController: UITabBarController

        public func makeUIViewController(context: Context) -> UITabBarController {
            return viewController
        }

        public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        }
    }

    func showTabPreview(_ deviceType: DeviceType = .iPhone15Pro) -> some View {
        TabPreview(viewController: self as! UITabBarController)
            .previewDevice(PreviewDevice(rawValue: deviceType.name()))
    }
}

#endif

