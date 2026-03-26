import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupWindow()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    // MARK: - Private Setup

    private func setupWindow() {
        let window = UIWindow()
        let tabBarController = makeTabBarController()

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        self.window = window
    }

    private func makeTabBarController() -> UITabBarController {
        let tabBarController = CustomTabBarController()
        tabBarController.viewControllers = [
            makeTrackersFlow(),
            makeStatisticsFlow()
        ]
        return tabBarController
    }

    private func makeTrackersFlow() -> UIViewController {
        let viewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        navigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .trackersIcon),
            selectedImage: UIImage(resource: .trackersIcon)
        )

        return navigationController
    }

    private func makeStatisticsFlow() -> UIViewController {
        let viewController = StatisticsViewController()

        viewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statisticsIcon),
            selectedImage: UIImage(resource: .statisticsIcon)
        )

        return viewController
    }

}

