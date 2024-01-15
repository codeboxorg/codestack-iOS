//
//  ToastV2.swift
//  CodestackApp
//
//  Created by 박형환 on 1/15/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import SwiftUI

enum ToastStyle {
    case error
    case success
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .success: return Color.green
        }
    }
    
    var iconFileName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

struct ToastValue: Equatable {
    var type: ToastStyle
    var title: String
    var message: String
    var duration: Double = 3
    
    static var sample: Self {
        .init(type: ToastStyle.error, title: "성공", message: "추가에 실패하였습니다.")
    }
}


struct ToastMessageViewV2: View {
    var value: ToastValue
    @State private var isHidden: Bool = false
    
    var onClicked: (Binding<Bool>) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: value.type.iconFileName)
                    .foregroundColor(value.type.themeColor)
                
                VStack(alignment: .leading) {
                    Text(value.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary.opacity(0.6))
                    
                    Text(value.message)
                        .font(.system(size: 12))
                        .foregroundColor(Color.primary.opacity(0.6))
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onClicked($isHidden)
                    print("Xmark Clicked")
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.black)
                }
            }
            .padding()
        }
        .background(isHidden ? .clear : Color(uiColor: UIColor.tertiarySystemBackground))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(value.type.themeColor)
                .frame(width: 8)
                
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: isHidden ? .clear : Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
        .opacity(isHidden ? .zero : 1)
    }
}

struct CustomToastStyle_Previews: PreviewProvider {
    static var previews: some View {
        let view = ToastMessageViewV2(value: ToastValue.sample, onClicked:{ _ in })
        return view
    }
}
