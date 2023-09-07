//
//  WKWebView-extension.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit
import WebKit

extension WKWebView{
    
    func htmlSetting(string: String) -> String{
        let htmlStart = "<!DOCTYPE html><head> <meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></head><body>"
        let htmlEnd = "</body></html>"
        return "\(htmlStart)\(string)\(htmlEnd)"
    }
    
    func makeWebView() -> WKWebView{
        guard let path = Bundle.main.path(forResource: "style", ofType: "css") else {
            return WKWebView()
        }
        
        let cssString = try! String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        
        Log.debug(cssString)
        
        let source = """
              var style = document.createElement('style');
              style.innerHTML = '\(cssString)';
              document.head.appendChild(style);
            """
        
        let userScript = WKUserScript(source: source,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero,
                                configuration: configuration)
        return webView
    }
}


