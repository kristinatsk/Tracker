import UIKit

final class CustomTabBarController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    
    private func setupAppearance() {
        let appearance = makeTabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.gray.cgColor
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
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
