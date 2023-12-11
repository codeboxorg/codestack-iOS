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
    
    static let codestackAPI: Package = .local(path: .relativeToRoot("Projects/CodestackAPI"))
    
}


public let dependencies = Dependencies(
    carthage: [],
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
                .sqlite,
                .swinject,
                .codestackAPI
            ],
            productTypes: [ : ],
            baseSettings: .settings(configurations: [
                .debug(name: "Dev"),
                .debug(name: "Prod"),
            ]),
            targetSettings: [:],
            projectOptions: [:])
    ,
    platforms: [.iOS]
)
