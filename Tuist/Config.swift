@preconcurrency import ProjectDescription

let config = Config(
    plugins: [
        .local(path: .relativeToRoot("Plugins/MyPlugin"))
    ]
)
