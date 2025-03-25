


@preconcurrency import ProjectDescription

let template = Template(
    description: "DemoFeature Create Template",
    attributes: [
        .required("name")
    ],
    items: [
        .file(path: "Projects/{{ name }}/Project.swift", templatePath: "Project.stencil"),
        .file(path: "Projects/{{ name }}/Sources/.keep", templatePath: "Sources/keep.stencil"),
        .file(path: "Config/{{ name }}.xcconfig", templatePath: "Config/config.stencil"),
        .file(path: "Projects/{{ name }}/{{ name }}Demo/Sources/AppDelegate.swift", templatePath: "Demo/Sources/AppDelegate.stencil"),
        .file(path: "Projects/{{ name }}/{{ name }}Demo/Sources/SceneDelegate.swift", templatePath: "Demo/Sources/SceneDelegate.stencil"),
        .file(path: "Projects/{{ name }}/{{ name }}Demo/Resources/LaunchScreen.storyboard", templatePath: "Demo/Resources/LaunchScreen.stencil"),
        .file(path: "Projects/{{ name }}/Tests/Test.swift", templatePath: "Tests/DemoTests.stencil")
    ]
)
