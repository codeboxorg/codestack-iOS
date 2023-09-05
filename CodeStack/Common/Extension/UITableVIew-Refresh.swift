//
//  BottomRefreshTableVIew.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/29.
//

import UIKit


extension UITableView{
    
    private var animationDuration: Double {
        0.2
    }
    
    private var bottomView: CustomBottomView {
        CustomBottomView()
    }
    
    func addBottomRefresh(width: CGFloat, height: CGFloat = 50){
        let bottomView = CustomBottomView()
        bottomView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.tableFooterView = bottomView
        
        UIView.animate(withDuration: animationDuration) {
            self.contentInset.bottom = 50
        }
    }
    
    func removeBottomRefresh(){
        DispatchQueue.main.async { [weak self] in
            if let self = self{
                UIView.animate(withDuration: self.animationDuration) {
                    self.tableFooterView = nil
                }
            }
        }
    }
}
