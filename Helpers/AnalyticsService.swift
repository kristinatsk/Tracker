import Foundation
import AppMetricaCore
import os

struct AnalyticsService {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Tracker", category: "Analytics")
    private static let apiKey = "9b3ab57e-2d03-40b9-ac76-371e89cd2ca3"
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params: [AnyHashable : Any]) {
        logger.info("Analytics: event sent \(event) with params \(params)")
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            logger.error("REPORT ERROR: \(error.localizedDescription)")
        })
    }
}
