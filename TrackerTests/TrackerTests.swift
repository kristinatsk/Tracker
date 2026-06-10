import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        let navController = UINavigationController(rootViewController: vc)
        
        
        assertSnapshot(matching: navController, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(matching: navController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}

