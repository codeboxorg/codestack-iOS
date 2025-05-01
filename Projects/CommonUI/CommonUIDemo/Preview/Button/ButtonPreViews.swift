



import SwiftUI
import CommonUI

@available(iOS 17.0, *)
struct PreviewWrapper: View {
    @State private var isLoading = false

    var body: some View {
        let button = HighlightButton()
        button.setTitle("안녕하세요", for: .normal)

        let numberButton = NumberButton()
        numberButton.settingNumber(for: 1)
        numberButton.settingText(for: "문제")

        return VStack {
            button.showPreview()
                .frame(width: 100, height: 30)

            AddGradientView()
                .showPreview()
                .frame(width: 50, height: 50)
                .padding(.top,10)

            BackButton()
                .showPreview()
                .frame(width: 44, height: 44)

            CommonHideButton()
                .showPreview()
                .frame(width: 30, height: 30)

            ButtonWrapper(
                button: LoadingUIButton(frame: .zero, title: "제출하기"),
                loading: $isLoading
            ) {
                isLoading = !isLoading
            }
            .frame(width: 120, height: 44)

            numberButton
                .showPreview()
                .frame(width: 80, height: 30)

            let register = RegisterButton.init(title: "회원가입")

            register
                .showPreview()
                .frame(width: .infinity, height: 44)
                .padding(.horizontal, 20)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PreviewWrapper()
}

