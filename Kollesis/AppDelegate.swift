import UIKit
import Alamofire

final class AppDelegate: NSObject, UIApplicationDelegate {
    private static let bind = "com.kollesis.roll"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        _ = Self.bind
        APIConfig.apply()
        return true
    }
}
