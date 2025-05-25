
@preconcurrency import ProjectDescription


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
    // static let codestackAPI: TargetDependency    = .external(name: "CodestackAPI")
    static let highlightr: TargetDependency = .external(name: "Highlightr")
    
    // static let firebase: TargetDependency = .external(name: "FirebaseFirestore")
    
    static let firebaseAuth: TargetDependency = .external(name: "FirebaseAnalyticsSwift")
    static let firebaseAnalyticsSwift: TargetDependency = .external(name: "FirebaseAuth")
    
    static let richText: TargetDependency = .external(name: "RichText")
    
    static let rxRelay: TargetDependency = .external(name: "RxRelay")
    static let rxTest: TargetDependency = .external(name: "RxTest")
    static let rxBlocking: TargetDependency = .external(name: "RxBlocking")
    static let reactorKit: TargetDependency = .external(name: "ReactorKit")
    static let swiftHanguel: TargetDependency = .external(name: "SwiftHangeul")
    static let swiftDown: TargetDependency = .external(name: "SwiftDown")
}

public enum P {
    public static let app: Path = .relativeToRoot("Projects/CodestackApp")
    public static let global: Path = .relativeToRoot("Projects/Module/Global")
    public static let data: Path = .relativeToRoot( "Projects/Data")
    public static let domain: Path = .relativeToRoot("Projects/Domain")
    public static let flow: Path = .relativeToRoot("Projects/Flow")
    public static let csNetwork: Path = .relativeToRoot("Projects/Module/CSNetwork")
    public static let thirdParty: Path = .relativeToRoot("Projects/Module/ThirdParty")
    public static let presentation: Path = .relativeToRoot("Projects/Presentation")
    public static let commonUI: Path = .relativeToRoot("Projects/CommonUI")
    public static let editor: Path = .relativeToRoot("Projects/Features/Editor")
}

public extension TargetDependency.PRO {
    static let editor = TargetDependency.project(
        target: "Editor",
        path: P.editor
    )
    
    static let global = TargetDependency.project(
        target: "Global",
        path: P.global
    )
    static let data = TargetDependency.project(
        target: "Data",
        path: P.data
    )
    static let domain = TargetDependency.project(
        target: "Domain",
        path: P.domain
    )
    static let flow = TargetDependency.project(
        target: "Flow",
        path: P.flow
    )
    
    static let commonUI = TargetDependency.project(
        target: "CommonUI",
        path: P.commonUI
    )
    
    static let csNetwork = TargetDependency.project(
        target: "CSNetwork",
        path: P.csNetwork
    )
    
    static let thridParty = TargetDependency.project(
        target: "ThirdParty",
        path: P.thirdParty
    )
    static let presentation = TargetDependency.project(
        target: "Presentation",
        path: P.presentation
    )
}
