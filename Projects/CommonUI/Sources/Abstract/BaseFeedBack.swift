//
//  FeedBack.swift
//  CommonUIDemoApp
//
//  Created by 박형환 on 6/3/24.
//  Copyright © 2024 com.hwan. All rights reserved.
//

import UIKit

@dynamicMemberLookup
public struct BaseFeedBack<B: UIButton> {
    
    public let button: B
    
    public init(
        _ button: B,
        _ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) {
        self.button = button
        button.addAction(
            UIAction { [weak button] value in
                button?.feedBackGenerate()
            },
            for: .touchUpInside
        )
    }
    
    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<B, Property>) -> Property  {
        button[keyPath: keyPath]
    }
}

private class F: NSObject {
    static let shared: F = F()
    override init() {}
    
}
