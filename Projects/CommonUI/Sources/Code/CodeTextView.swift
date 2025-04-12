
import UIKit
import Highlightr

public class CodeUITextView: UITextView {
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.backgroundColor = .black
        self.layer.borderColor = UIColor.black.cgColor
        self.tintColor = .whiteGray
        self.inputView?.tintColor = dynamicLabelColor
        self.isScrollEnabled = true
        self.layer.borderWidth = 1
        self.spellCheckingType = .no
        self.alwaysBounceVertical = true
        self.textContainer.widthTracksTextView = false
        self.textContainer.lineBreakMode = .byClipping
        
        self.autocorrectionType = .no         // 자동 수정 비활성화
        self.autocapitalizationType = .none   // 자동 대문자 비활성화
        self.smartDashesType = .no            // 스마트 대시(- → —) 비활성화
        self.smartQuotesType = .no            // 스마트 인용부호(" → “ ”) 비활성화
        self.smartInsertDeleteType = .no      // 스마트 삽입/삭제 비활성화
        self.keyboardType = .default          // 키보드 종류
        self.spellCheckingType = .no          // 맞춤법 검사 비활성화
        
        self.text = """

#include <stdio.h>
    
int main() {

    return 0;
}
"""
    }
    
    public override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
        guard let font = self.font else { return superRect }
        superRect.size.height = font.pointSize - font.descender
        return superRect
    }
    
    required init?(coder: NSCoder) {
        fatalError("fattal error in codeUITextView this is not by using Storyboard")
    }
    
    deinit{
        #if DEBUG
        print("CodeUITextView : deinit")
        #endif
    }
    
    fileprivate func addAttributes(){
        self.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    private var isFirst: Bool = true
    
    public func languageBinding(name: String) {
        let storage = (self.textStorage as! CodeAttributedString)
        
        if name == "Node" || name == "Node.js" {
            storage.language = "typescript"
        } else {
            if name == "Python3" {
                storage.language = "python"
            } else {
                storage.language = "\(name)"
            }
        }
    }
    
    public func textBinding(sourceCode: String) {
        self.text = sourceCode
    }
}

