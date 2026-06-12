import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "9b3ab57e-2d03-40b9-ac76-371e89cd2ca3") else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params: [AnyHashable : Any]) {
        print("Analytics: event sent \(event) with params \(params)")
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
