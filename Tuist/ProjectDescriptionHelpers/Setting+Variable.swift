//
//  Setting.swift
//  ProjectDescriptionHelpers
//
//  Created by 박형환 on 12/16/23.
//

import ProjectDescription



public enum CSettings {
    case objc
    case defaults
    
    public var value: ProjectDescription.SettingsDictionary {
        switch self {
        case .objc:
            return ["OTHER_LDFLAGS": "$(OTHER_LDFLAGS) -ObjC"]
        default:
            return [
                "OTHER_LDFLAGS": "$(inherited)"
            ]
        }
    }
}

//"SWIFT_ACTIVE_COMPILATION_CONDITIONS" : DEBUG, QA etc..

let appBuildSetting: Settings = .settings(configurations: [
    .debug(name: "Dev",
           settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("DEBUG"),],
           xcconfig: "Config/Codestack.xcconfig"),
    .release(name: "Prod",
           settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("PROD")],
           xcconfig: "Config/Codestack.xcconfig"),
  ])

let targetSetting: [ProjectDescription.Configuration] = [
     .debug(name: "Dev",
            settings: [
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("DEBUG"),
            ],
            xcconfig: "Config/Codestack.xcconfig"),
     .release(name: "Prod",
              settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("PROD")],
              xcconfig: "Config/Codestack.xcconfig")
]


let defalutBuildSetting: Settings = .settings(configurations: [
    .debug(name: "Dev", 
           xcconfig: .relativeToRoot("Projects/CodestackApp/Config/Dev.xcconfig")),
    .release(name: "Prod",
             xcconfig: .relativeToRoot("Projects/CodestackApp/Config/Prod.xcconfig"))
])


let defaultTargetSetting: [ProjectDescription.Configuration] = [
    .debug(name: "Dev",
           settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("DEBUG")]),
    .release(name: "Prod",
             settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": .string("PROD")])
]


//func generateSchemes(_ name: String) -> [Scheme] {
//    [
//        
//        Scheme(name: "\(name)",
//               shared: true,
//               buildAction: .buildAction(targets: ["\(name)"]),
//               testAction: .targets(
//                ["\(name)Tests"],
//                configuration: .configuration("Dev"),
//                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
//               ),
//               runAction: .runAction(
//                configuration: .configuration("Dev")
//               ),
//               archiveAction: .archiveAction(configuration: .configuration("Dev")),
//               profileAction: .profileAction(configuration: .configuration("Dev")),
//               analyzeAction: .analyzeAction(configuration: .configuration("Dev"))),
//        
//        Scheme(name: "\(name)-Prod",
//               shared: true,
//               buildAction: .buildAction(targets: ["\(name)"]),
//               runAction: .runAction(configuration: .configuration("Prod")),
//               archiveAction: .archiveAction(configuration: .configuration("Prod")),
//               profileAction: .profileAction(configuration: .configuration("Prod")),
//               analyzeAction: .analyzeAction(configuration: .configuration("Prod")))
//        ]
//}
