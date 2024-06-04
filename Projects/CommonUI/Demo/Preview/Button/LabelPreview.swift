
import SwiftUI
import CommonUI
import UIKit

@available(iOS 17.0, *)
#Preview {
    let box =
    BoxContainerLabel.init(
        color: .dynamicLabelColor,
        text: "문제제출 현황",
        border: .sky_blue
    )
    let box1 =
    BoxContainerLabel.init(
        color: .dynamicLabelColor,
        text: "문제 결과",
        border: .sky_blue
    )
    let box2 =
    BoxContainerLabel.init(
        color: .dynamicLabelColor,
        text: "제출 결과",
        border: .sky_blue
    )
    let box3 =
    BoxContainerLabel.init(
        color: .dynamicLabelColor,
        text: "제출 아이디",
        border: .sky_blue
    )
    let box4 =
    BoxContainerLabel.init(
        color: .dynamicLabelColor,
        text: "제출자",
        border: .sky_blue
    )
    
    let sub =
    BoxContainerLabel.init(
        color: .red,
        text: "문제에 실패하셨습니다.",
        border: .red
    )
    
    return VStack {
        HStack {
            box.showPreview()
                .frame(
                    width: box.maxWidth,
                    height: box.maxHeight
                )
            
            sub.showPreview()
                .frame(
                    width: sub.maxWidth,
                    height: sub.maxHeight
                )
        }
        box1.showPreview()
            .frame(
                width: box1.maxWidth,
                height: box1.maxHeight
            )
        box2.showPreview()
            .frame(
                width: box2.maxWidth,
                height: box2.maxHeight
            )
        box3.showPreview()
            .frame(
                width: box3.maxWidth,
                height: box3.maxHeight
            )
        box4.showPreview()
            .frame(
                width: box4.maxWidth,
                height: box4.maxHeight
            )

    }.onAppear {
    }
}
