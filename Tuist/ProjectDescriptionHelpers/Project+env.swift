//
//  Env.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/16/23.
//

import ProjectDescription

public struct Environment {
    public let organizationName: String
    public let deploymentTarget: DeploymentTargets
    public let platform: Platform
}

public let env15 = Environment(
    organizationName: "com.hwan",
    deploymentTarget: .iOS("15.0"),
    platform: .iOS
)

public let env13 = Environment(
    organizationName: "com.hwan",
    deploymentTarget: .iOS("13.0"),
    platform: .iOS
)
