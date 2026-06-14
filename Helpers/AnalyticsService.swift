import Foundation
import AppMetricaCore
import os

enum MainScreenEvent: String {
    case open
    case close
    case click
}

enum AnalyticsKey: String {
    case screen
    case item
}

enum AnalyticsValue: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
    case main = "Main"
}

struct AnalyticsService {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Tracker", category: "Analytics")
    private static let apiKey = "9b3ab57e-2d03-40b9-ac76-371e89cd2ca3"
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func report(event: MainScreenEvent, params: [AnalyticsKey : AnalyticsValue]) {
        var stringParams: [String: String] = [:]
        
        for (key, value) in params {
            stringParams.updateValue(value.rawValue, forKey: key.rawValue)
        }
        
        logger.info("Analytics: event sent \(event.rawValue) with params \(stringParams)")
        AppMetrica.reportEvent(name: event.rawValue, parameters: stringParams, onFailure: { error in
            logger.error("REPORT ERROR: \(error.localizedDescription)")
        })
    }
}
