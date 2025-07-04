//
//  SwiftEditorViewModel.swift
//  CodestackApp
//
//  Created by 박형환 on 4/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import SwiftUI
import SwiftDown
import Combine



enum UserInterface {
    case dark
    case light
    case unspecified
}

extension SwiftDownEditor {
    final class ViewModel: ObservableObject {
        @Published var content: String = "내용을 입력해주세요"
        @Published var userInterfaceMode: UserInterface = .unspecified
        private let output: WritePostingViewModel
        private var subscriptions = Set<AnyCancellable>()
        
        init(_ writeViewModel: WritePostingViewModel) {
            self.output = writeViewModel
            bind()
        }
        
        private func bind() {
            self.$content
                .sink(receiveValue: { [weak self] in
                    self?.output.contentInput.onNext($0)
                }).store(in: &subscriptions)
        }
    }
}
