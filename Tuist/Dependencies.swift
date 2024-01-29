//
//  Dependencies.swift
//  CodeStackManifests
//
//  Created by 박형환 on 12/10/23.
//

import ProjectDescription


public extension Package {
    static let rxSwift: Package = .remote(url: "https://github.com/ReactiveX/RxSwift.git",
                                          requirement: .upToNextMajor(from: "6.5.0"))
    
    static let snapKit: Package = .remote(url: "https://github.com/SnapKit/SnapKit",
                                          requirement: .upToNextMinor(from: "5.6.0"))
    
    static let then: Package = .remote(url: "https://github.com/devxoul/Then",
                                       requirement: .upToNextMajor(from: "2.7.0"))
    
    static let apollo: Package = .remote(url: "https://github.com/apollographql/apollo-ios.git",
                                         requirement: .upToNextMajor(from: "1.7.1"))
    
    static let richtextKit: Package = .remote(url: "https://github.com/danielsaidi/RichTextKit.git",
                                              requirement: .upToNextMajor(from: "0.9.4"))
    
    static let rxdatasources: Package = .remote(url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
                                                requirement: .upToNextMajor(from: "5.0.2"))
    
    static let rxFlow: Package = .remote(url: "https://github.com/RxSwiftCommunity/RxFlow.git",
                                         requirement: .upToNextMajor(from: "2.13.0"))
    
    static let rxGesture: Package = .remote(url: "https://github.com/RxSwiftCommunity/RxGesture.git",
                                            requirement: .upToNextMajor(from: "4.0.4"))
    
    static let sqlite: Package = .remote(url: "https://github.com/stephencelis/SQLite.swift.git",
                                         requirement: .upToNextMajor(from: "0.14.1"))
    
    static let swinject: Package = .remote(url: "https://github.com/Swinject/Swinject.git",
                                           requirement: .upToNextMajor(from: "2.8.4"))
    
    static let codestackAPI: Package = .local(path: .relativeToRoot("Projects/Module/CodestackAPI"))
    
    static let highlightr: Package = .local(path: .relativeToRoot("Projects/Module/Highlightr"))
    
    static let firebase: Package = .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.19.1"))
    
    static let richText: Package = .remote(url: "https://github.com/NuPlay/RichText.git", requirement: .upToNextMajor(from: "2.0.0"))
    
    static let reactorKit: Package = .remote(url: "https://github.com/ReactorKit/ReactorKit.git", requirement: .upToNextMajor(from: "3.2.0"))
}

public let dependencies = Dependencies(
    carthage: nil,
    swiftPackageManager:
        SwiftPackageManagerDependencies.init(
            [
                .rxSwift,
                .snapKit,
                .then,
                .apollo,
                .richtextKit,
                .rxdatasources,
                .rxFlow,
                .rxGesture,
                .swinject,
                .codestackAPI,
                .highlightr,
                .firebase,
                .richText,
                .reactorKit,
            ],
            productTypes: [// "CodestackAPI" : .framework ,
                "ApolloAPI" : .staticFramework,
                "Apollo" : .staticFramework,
                "Highlightr" : .staticFramework ,
                "SQLite" : .framework],
            baseSettings: .settings(configurations: [
                .debug(name: "Dev"),
                .release(name: "Prod"),
            ]),
            targetSettings: [ : ],
            projectOptions: [:])
    ,
    platforms: [.iOS]
)
