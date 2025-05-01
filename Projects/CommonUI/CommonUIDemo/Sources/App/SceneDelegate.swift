

import UIKit
import Global

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

    func sceneDidDisconnect(_ scene: UIScene) {
        // 리소스를 해제하거나 상태를 저장하는 데 사용
        Log.debug("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 활성화되었을 때
        Log.debug("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 앱이 비활성화되기 직전에 호출
        Log.debug("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 앱이 백그라운드에서 포그라운드로 이동할 때
        Log.debug("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 백그라운드로 들어갈 때
        Log.debug("sceneDidEnterBackground")
    }
}
