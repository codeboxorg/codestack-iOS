//
//  Configuration.swift
//  CommonUI
//
//  Created by 박형환 on 2/1/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation



public enum Style {
    
    public static var css: String {
        """
        \(blockQuote)
        \(codeBlockCss)
        \(list)
        """
    }
    
    public static var list: String {
        """
        #wrap ul {
            padding:40px 40px 40px 100px;
            -webkit-columns: 320px;
            -moz-columns: 320px;
            columns: 320px;
        }

        #wrap li {
            border: 1px solid #333333;
            border-radius: 15px;
            height:200px;
            width:300px;
            background:#ebebeb;
            padding: 10px 0px 0px 20px;
            text-align:center;
            background-size: 30px 30px;
            background-position: 80px;
            background-repeat:no-repeat;
            padding: 10px 0 0 34px;
            -webkit-column-break-inside: avoid;
            break-inside: avoid;
        }
        """
    }
    
    public static var blockQuote: String {
        """
        blockquote {
          margin: 10;
        }

        blockquote p {
          padding: 15px;
          background: #2F2F2F;
          border-radius: 5px;
        }

        blockquote p::before {
          content: \'\\201C\';
        }

        blockquote p::after {
          content: \'\\201D\';
        }
        """
    }
    
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
