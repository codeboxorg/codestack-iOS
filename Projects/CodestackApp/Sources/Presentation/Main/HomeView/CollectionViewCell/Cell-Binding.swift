//
//  WritingListCell-Binding.swift
//  CodestackApp
//
//  Created by 박형환 on 1/14/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation
import RxSwift
import Domain
import Global
import CommonUI

extension WritingListCell {
    var binder: Binder<StoreVO> {
        Binder<StoreVO>(self) { cell,value  in
            cell.titleTagView.setText(text: "\(value.title)")
            cell.applyTitleTagSize()
            cell.descriptionLabel.text = value.description
            cell.dateLabel.text = value.date
            cell.tags = nil
            cell.tags = value.tags
            
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
        descriptionLabel.addSkeletonView()
        dateLabel.addSkeletonView()
        colorline.addSkeletonView()
        tagContainer.subviews.forEach {
            $0.addSkeletonView()
        }
    }
}

extension PRSubmissionHistoryCell {
    var binder: Binder<(SubmissionVO)> {
        Binder<SubmissionVO>(self) { cell, submission in
            cell.titleLabel.text = submission.problem.title
            if let solvedDate = submission.createdAt.toDateStringUTCORKST(format: .FULL){
                let dateString = DateCalculator().caluculateTime(solvedDate)
                cell.dateLabel.text = dateString
            }
            let status = submission.statusCode.convertSolveStatus()
            cell.statusLabel.pr_status_label(status)
            
            if submission.isMock {
                cell.layoutIfNeeded()
                cell.titleLabel.addSkeletonView()
                cell.dateLabel.addSkeletonView()
                cell.statusLabel.addSkeletonView()
            } else {
                cell.contentView.removeSkeletonViewFromSuperView()
            }
        }
    }
}
