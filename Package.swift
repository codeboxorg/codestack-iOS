

// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [ 
            // "SwiftHangeul" : .staticFramework,
            "CodestackAPI" : .framework ,
            "ApolloAPI" : .staticFramework,
            "Apollo" : .staticFramework,
            "Highlightr" : .staticFramework ,
            "SQLite" : .framework],
        baseSettings: .settings(configurations: [
            .debug(name: "Dev"),
            .release(name: "Prod"),
        ]),
        platforms: [.iOS]
    )
#endif


let package = Package(
    name: "name",
    dependencies: [
        .package(url: "https://github.com/hyeonghwan/SwiftHangeul.git", from: "0.1.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.6.0"),
        .package(url: "https://github.com/devxoul/Then", from: "2.7.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk" ,from: "10.19.1"),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", from: "3.2.0"),
        .package(url: "https://github.com/Swinject/Swinject.git" , from: "2.8.8"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.4"),
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.7.1"),
        .package(url: "https://github.com/danielsaidi/RichTextKit.git", from: "0.9.4"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git",from:  "5.0.2"),
        .package(url: "https://github.com/RxSwiftCommunity/RxFlow.git",from:  "2.13.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git",from:  "0.14.1"),
        .package(path: "Projects/Module/CodestackAPI"),
        .package(path: "Projects/Module/Highlightr"),
        .package(url: "https://github.com/NuPlay/RichText.git", from: "2.0.0"),
        .package(url: "https://github.com/qeude/SwiftDown.git", from: "0.4.1")
    ]
)
