

import UIKit

enum ToolBarGenerator {
    static func makeToolBar(_ buttons: [UIButton]) -> (toolbar: UIToolbar, height: CGFloat) {
        let toolBar = UIToolbar(
            frame: CGRect(
                origin: CGPoint.zero,
                size: CGSize(
                    width: UIScreen.main.bounds.width,
                    height: CGFloat(44)
                )
            )
        )
        toolBar.barStyle = .default
        toolBar.tintColor = .whiteGray

        let (scrollView, stackViewInScrollView) = _containerView()
        let done = buttons[0]
        
        
        buttons[1...].enumerated().forEach { enumerated in
            let (offset, button) = enumerated
            if button.accessibilityIdentifier == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.moveLeftButton.string {
                stackViewInScrollView.addArrangedSubview(_makeSeparator())
            } else if button.accessibilityIdentifier == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.symbolAlertButton.string {
                stackViewInScrollView.addArrangedSubview(_makeSeparator())
            } else if button.accessibilityIdentifier == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.undoButton.string {
                stackViewInScrollView.addArrangedSubview(_makeSeparator())
            } else if button.accessibilityIdentifier == DefaultButtonCommandExecuteManager.AccessoryButtonIdentifier.deleteLineButton.string {
                stackViewInScrollView.addArrangedSubview(_makeSeparator())
            }
            stackViewInScrollView.addArrangedSubview(button)
        }
        
        let doneItem = UIBarButtonItem(customView: done)
        let separator = UIBarButtonItem(customView: _makeSeparator())
        let scrollItem = UIBarButtonItem(customView: scrollView)
        
        toolBar.items = [scrollItem, separator, doneItem]
        toolBar.sizeToFit()
        let toolBarSize = toolBar.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat(50)))
        return (toolBar, toolBarSize.height)
    }
    
    private static func _containerView() -> (UIScrollView, UIStackView) {
        let scrollView = __scrollViewiew()
        let stackView = __stackView()
        
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        return (scrollView, stackView)
    }
    
    private static func _makeSeparator(height: CGFloat = 20, color: UIColor = .lightGray, horizontalPadding: CGFloat = 4) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = color

        container.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: horizontalPadding),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -horizontalPadding),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: height)
        ])

        return container
    }
    
    private static func __stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func __scrollViewiew() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 60, height: 44))
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }
}
