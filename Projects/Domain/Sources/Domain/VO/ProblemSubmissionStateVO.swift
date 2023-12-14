//
//  ProblemStateVO.swift
//  CodestackApp
//
//  Created by 박형환 on 12/13/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import Foundation

public struct ProblemSubmissionStateVO {
    public var submissions: [SubmissionVO]
    
    public init(submissions: [SubmissionVO]) {
        self.submissions = submissions
    }
}
