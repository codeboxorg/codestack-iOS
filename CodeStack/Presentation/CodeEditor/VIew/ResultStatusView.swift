//
//  PagingTableView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/16.
//

import UIKit


class PagingTableView: UITableView{
    
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("PagingTableView required init fatal Error")
    }

}


