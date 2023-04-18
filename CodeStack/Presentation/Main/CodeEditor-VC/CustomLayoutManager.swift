//
//  CustomLayoutManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/19.
//

import UIKit


class CustomLayoutManager: NSLayoutManager{
    
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        print("glyphsToShow : \(glyphsToShow)")
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
    }
    
}

