import CommonUI
import UIKit
import SwiftUI


struct ButtonWrapper<Button: Loading>: UIViewRepresentable {
    let button: Button
    @Binding var loading: Bool
    var action: () -> Void
    
    func makeUIView(context: Context) -> Button {
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.buttonTapped),
            for: .touchUpInside
        )
        return button
    }
    
    func updateUIView(_ uiView: Button, context: Context) {
        if loading {
            uiView.showLoading()
        } else {
            uiView.hideLoading()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(button: button, action: action)
    }

    class Coordinator {
        let button: Button
        let action: () -> Void
        
        init(button: Button, action: @escaping () -> Void) {
            self.button = button
            self.action = action
        }

        @objc func buttonTapped() {
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.action()
            }
        }
    }
}
