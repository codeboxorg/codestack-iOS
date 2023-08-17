//
//  UIImage-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/17.
//

import UIKit


extension UIImage{
    func baseOffset(size: CGFloat = 10) -> UIImage{
        return self.withBaselineOffset(fromBottom: size)
    }
}


