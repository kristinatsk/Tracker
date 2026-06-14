import UIKit

final class Colors {
    static var collectionViewBackgroundColor: UIColor = .systemBackground
    
    static var navigationTintColor: UIColor = UIColor { (traits) -> UIColor in
        let isDarkMode = traits.userInterfaceStyle == .dark
        return isDarkMode ? UIColor.white : UIColor.black
    }
}
