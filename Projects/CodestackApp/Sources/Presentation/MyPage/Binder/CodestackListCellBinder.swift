//
//  CodestackListCellBinder.swift
//  CodestackApp
//
//  Created by 박형환 on 3/3/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import CommonUI
import Global

extension CodestackListCell {
    
    var binder: Binder<CodestackVO> {
        Binder<CodestackVO>(self) { cell,value  in
            cell.titleTagView.setText(text: "\(value.name)")
            cell.applyTitleTagSize()
            cell.languageBtn.setTitle(value.languageVO.name, for: .normal)
            
            if let solvedDate = value.createdAt.toDateStringUTCORKST(format: .FULL){
                let dateString = DateCalculator().caluculateTime(solvedDate)
                cell.dateLabel.text = dateString
            }
            
            if value.isMock {
                cell.layoutIfNeeded()
                cell.addSkeletonView()
            } else {
                cell.contentView.removeSkeletonViewFromSuperView()
            }
        }
    }
    
    private func addSkeletonView() {
        titleTagView.addSkeletonView()
        dateLabel.addSkeletonView()
        colorline.addSkeletonView()
    }
}

