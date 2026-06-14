import UIKit

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var weekName: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "")
        case .tuesday: return NSLocalizedString("tuesday", comment: "")
        case .wednesday: return NSLocalizedString("wednesday", comment: "")
        case .thursday: return NSLocalizedString("thursday", comment: "")
        case .friday: return NSLocalizedString("friday", comment: "")
        case .saturday: return NSLocalizedString("saturday", comment: "")
        case .sunday: return NSLocalizedString("sunday", comment: "")
        }
    }
    
    init?(calendarWeekday: Int) {
        switch calendarWeekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
    
    init?(scheduleIndex: Int) {
        switch scheduleIndex {
        case 0: self = .monday
        case 1: self = .tuesday
        case 2: self = .wednesday
        case 3: self = .thursday
        case 4: self = .friday
        case 5: self = .saturday
        case 6: self = .sunday
        default: return nil
        }
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    var isPinned = false
}
