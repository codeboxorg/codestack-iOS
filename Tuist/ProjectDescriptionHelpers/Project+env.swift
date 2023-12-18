//
//  Env.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/16/23.
//

import ProjectDescription

public struct Environment {
    public let organizationName: String
    public let deploymentTarget: DeploymentTarget
    public let platform: Platform
}

public let env = Environment(
    organizationName: "hyeong",
    deploymentTarget: .iOS(targetVersion: "15.0", 
                           devices: .iphone,
                           supportsMacDesignedForIOS: true),
    platform: .iOS
)