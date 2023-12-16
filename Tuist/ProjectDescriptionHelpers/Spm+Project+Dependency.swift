
import ProjectDescription



public extension TargetDependency {
    enum PRO {}
    enum MOD {}
    enum SPM {}
}

public extension TargetDependency.SPM {
    static let rxSwift: TargetDependency = .external(name: "RxSwift")
    static let snapKit: TargetDependency = .external(name: "SnapKit")
    static let then: TargetDependency    = .external(name: "Then")
    static let apollo: TargetDependency = .external(name: "Apollo")
    static let richtextKit: TargetDependency = .external(name: "RichTextKit")
    static let rxdatasources: TargetDependency    = .external(name: "RxDataSources")
    static let rxFlow: TargetDependency = .external(name: "RxFlow")
    static let rxGesture: TargetDependency = .external(name: "RxGesture")
    static let swinject: TargetDependency = .external(name: "Swinject")
    static let sqlite: TargetDependency    = .external(name: "SQLite")
    static let codestackAPI: TargetDependency    = .external(name: "CodestackAPI")
    static let highlightr: TargetDependency = .external(name: "Highlightr")
}

public extension TargetDependency.PRO {
    static let global = TargetDependency.project(
        target: "Global",
        path: .relativeToRoot("Projects/Global")
    )
    static let data = TargetDependency.project(
        target: "Data",
        path: .relativeToRoot("Projects/Data")
    )
    static let domain = TargetDependency.project(
        target: "Domain",
        path: .relativeToRoot("Projects/Domain")
    )
    static let flow = TargetDependency.project(
        target: "Flow",
        path: .relativeToRoot("Projects/Flow")
    )
    
    static let thridParty = TargetDependency.project(
        target: "ThirdParty",
        path: .relativeToRoot("Projects/Module/ThirdParty")
    )
    static let presentation = TargetDependency.project(
        target: "Presentation",
        path: .relativeToRoot("Projects/Presentation")
    )
}
