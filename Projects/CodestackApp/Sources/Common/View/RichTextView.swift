//
//  RIchTextView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/26.
//

import UIKit
import SnapKit
import RichTextKit
import Global
import Domain

class RichTextViewController: UIViewController{

    private var attributedString: NSAttributedString?
    
    private lazy var richTextView: RichTextView = {
        var rich = RichTextView()
        
        do{
            rich = RichTextView(string: attributedString!)
        } catch {
            Log.debug("html parsing error")
        }
        return rich
    }()

    
    func htmlToAttributedString(string: String) -> NSAttributedString? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }
        return attributedString
    }
    
    
    static func create(with html: [ProblemVO]) -> RichTextViewController {
        let vc = RichTextViewController()
        let problems = html
        
        let context = problems.map{ data in
            print("------------------------")
           print("context::: \( data.context)")
            print("------------------------")
            return data.context
        }
     
        var ns = NSMutableAttributedString()
        
        context.forEach{ con in
            ns.append(con.htmlToAttributedString(font: UIFont.boldSystemFont(ofSize: 17), color: UIColor.label, lineHeight: 20) ?? NSAttributedString())
        }
        
        vc.attributedString = ns
        
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        layoutConfigure()
    }
    
    
    func layoutConfigure(){
        
        self.view.addSubview(richTextView)
        richTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
}
