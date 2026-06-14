import UIKit

final class CustomTabBarController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    
    private func setupAppearance() {
        let appearance = makeTabBarAppearance()
        tabBar.standardAppearance = appearance
        
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
    }

}


private extension CustomTabBarController {
    
    func makeTabBarAppearance() -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .systemBackground
        
        return appearance
    }
}
