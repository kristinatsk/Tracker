import UIKit

enum WeekDay {
    case monday, teusday, wednsday, thursday, friday, saturday, sunday
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
