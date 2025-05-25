

import UIKit
import Editor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // 씬이 연결될 때 호출됩니다.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = CodeViewController() // 초기 ViewController 설정
        self.window = window
        window.makeKeyAndVisible()
    }

}
