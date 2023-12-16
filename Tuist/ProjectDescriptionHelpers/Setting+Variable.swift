//
//  Setting.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/16/23.
//

import ProjectDescription

let appBuildSetting: Settings = .settings(configurations: [
    .debug(name: "Dev",
           settings: [:],
           xcconfig: "Config/BuildSetting.xcconfig"),
    .debug(name: "Prod",
           settings: [:],
           xcconfig: "Config/BuildSetting.xcconfig"),
  ])

let targetSetting: [ProjectDescription.Configuration] = [
     .debug(name: "Dev",
            settings: [:],
            xcconfig: "Config/Codestack.xcconfig"),
     .debug(name: "Prod",
            settings: [:],
            xcconfig: "Config/Codestack.xcconfig")
]

let defalutBuildSetting: Settings = .settings(configurations: [
    .debug(name: "Dev"),
    .debug(name: "Prod")
])


let defaultTargetSetting: [ProjectDescription.Configuration] = [
    .debug(name: "Dev",
           settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("DEBUG")]),
    .debug(name: "Prod",
           settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("PROD")])
]


func generateSchemes(_ name: String) -> [Scheme] {
    [
        Scheme(name: "\(name)-Dev",
               shared: true,
               buildAction: .buildAction(targets: ["\(name)"]),
               testAction: .targets(["\(name)Tests"],
                                    configuration: .configuration("Dev"),
                                    options: .options(coverage: true)),
               runAction: .runAction(configuration: .configuration("Dev"),
                                     arguments: .init(environment: ["OS_ACTIVITY_MODE" : "disable"],
                                                      launchArguments: [])),
               archiveAction: .archiveAction(configuration: .configuration("Dev")),
               profileAction: .profileAction(configuration: .configuration("Dev")),
               analyzeAction: .analyzeAction(configuration: .configuration("Dev"))),
        Scheme(name: "\(name)-Prod",
               shared: true,
               buildAction: .buildAction(targets: ["\(name)"]),
               runAction: .runAction(configuration: .configuration("Prod")),
               archiveAction: .archiveAction(configuration: .configuration("Prod")),
               profileAction: .profileAction(configuration: .configuration("Prod")),
               analyzeAction: .analyzeAction(configuration: .configuration("Prod")))
        ]
}
