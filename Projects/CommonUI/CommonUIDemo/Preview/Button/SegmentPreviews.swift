
import SwiftUI
import CommonUI
import UIKit

@available(iOS 17.0, *)
#Preview {
    let control = CommonHistorySegmentedControl(
        frame: .zero,
        types: ["전체", "즐겨찾기", "성공", "실패"]
    )
    control.selectedSegmentIndex = 0
    return VStack {
     control
            .showPreview()
            .frame(
                width: .infinity,
                height: 40
            )
            .padding(.horizontal, 10)
        
        Spacer()
    }.onAppear {
        control.layer.setNeedsDisplay()
        control.addTarget(
            SegControll.shared,
            action: #selector(SegControll.shared.handle(_:)),
            for: .valueChanged
        )
    }
}

class SegControll: NSObject {
    static let shared = SegControll()
    @objc func handle(_ sender: UISegmentedControl) {
        sender.layer.setNeedsDisplay()
    }
}
