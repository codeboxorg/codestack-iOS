//
//  RichTextView-SwiftUI.swift
//  CodestackApp
//
//  Created by 박형환 on 4/19/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import SwiftUI
import RichText
import CommonUI

struct RichTextSwiftUIView: View {
    
    @State private var delayHTML: String = ""
    private var setRichTextHeightAction: (CGFloat) -> Void
    private var HTML: String
    init(_ html: String, _ setRichTextHeightAction: @escaping (CGFloat) -> Void) {
        self.HTML = html
        self.setRichTextHeightAction = setRichTextHeightAction
    }

    var body: some View {
        makeRichTextView(delayHTML)
            .task {
                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                } catch { }
                delayHTML = HTML
            }
    }

    private func makeRichTextView(_ html: String) -> some View {
        let view = RichText(html: html)
            .colorScheme(.auto)
            .fontType(.system)
            .linkOpenType(.SFSafariView())
            .customCSS(Style.css)
            .placeholder {
                SkeletonUIKit()
                    .frame(
                        width: Position.screenWidth,
                        height: Position.screenHeihgt
                    )
            }
            .tint(CColor.sky_blue.sColor)
            .onReadSize { size in
                setRichTextHeightAction(size.height + 20)
            }
            
        return view
    }
}
