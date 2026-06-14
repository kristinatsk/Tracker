import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//MARK: - Properties
    
    var window: UIWindow?

//MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        window?.rootViewController = UserDefaults.standard.bool(forKey: "hasSeenOnboarding"
        )
        ? makeMainTabBarController()
        : OnboardingViewController()


        window?.makeKeyAndVisible()
    }
    
//MARK: - Private Methods
    private func makeMainTabBarController() -> UITabBarController {
                
            let tabBarController = CustomTabBarController()
            
            let trackersViewController = TrackersViewController()
            let trackersNavigation = UINavigationController(rootViewController: trackersViewController)
          
            trackersNavigation.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: ""), image: UIImage(resource: .trackersIcon), selectedImage: nil)
            
            let statisticsViewController = StatisticsViewController()
            let statisticsNavigation = UINavigationController(rootViewController: statisticsViewController)
            statisticsNavigation.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics", comment: ""), image: UIImage(resource: .statisticsIcon), selectedImage: nil)
            
            tabBarController.viewControllers = [trackersNavigation, statisticsNavigation]
            
        return tabBarController
        
    }

}

