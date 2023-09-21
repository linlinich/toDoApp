import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var navigationController = UINavigationController()

    var coordinator: CoordinatorProtocol?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationController
        
        coordinator = Coordinator()
        coordinator?.start(navigationController: navigationController)
    }
}


