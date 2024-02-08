//
//  Configuration.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation



public enum Style {
    public static var codeBlockCss: String {
        """
        pre code {
          display: block;
          background: none;
          white-space: pre;
          -webkit-overflow-scrolling: touch;
          overflow-x: scroll;
          max-width: 100%;
          min-width: 100px;
          padding: 0;
        }
        """
    }
}
