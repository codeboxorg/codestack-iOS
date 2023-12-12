//
//  CodeEditorStepper.swift
//  CodestackApp
//
//  Created by 박형환 on 12/12/23.
//  Copyright © 2023 hyeong. All rights reserved.
//

import RxFlow
import RxRelay

final class CodeEditorStepper: Stepper {
    var steps: PublishRelay<Step> = PublishRelay<Step>()
}

