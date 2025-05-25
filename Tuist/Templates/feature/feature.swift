


@preconcurrency import ProjectDescription

let template = Template(
    description: "DemoFeature Create Template",
    attributes: [
        .required("name")
    ],
    items: [
        .file(path: "Projects/Features/{{ name }}/Project.swift", templatePath: "Project.stencil"),
        .file(path: "Projects/Features/{{ name }}/Sources/.keep", templatePath: "Sources/keep.stencil"),
        .file(path: "Projects/Features/{{ name }}/Resources/.keep", templatePath: "Sources/keep.stencil"),
        .file(path: "Projects/Features/{{ name }}/Tests/{{ name }}Test.swift", templatePath: "Tests/DemoTests.stencil"),
        .file(path: "Config/{{ name }}.xcconfig", templatePath: "Config/config.stencil"),
        .file(path: "Projects/Features/{{ name }}/{{ name }}Demo/Sources/AppDelegate.swift", templatePath: "Demo/Sources/AppDelegate.stencil"),
        .file(path: "Projects/Features/{{ name }}/{{ name }}Demo/Sources/SceneDelegate.swift", templatePath: "Demo/Sources/SceneDelegate.stencil"),
        .file(path: "Projects/Features/{{ name }}/{{ name }}Demo/Resources/LaunchScreen.storyboard", templatePath: "Demo/Resources/LaunchScreen.stencil"),
        .file(path: "Projects/Features/{{ name }}/{{ name }}Demo/UITests/Test.swift", templatePath: "Tests/DemoTests.stencil"),
        .file(path: "Projects/Features/{{ name }}/{{ name }}Demo/Tests/Test.swift", templatePath: "Tests/DemoTests.stencil")
    ]
)
