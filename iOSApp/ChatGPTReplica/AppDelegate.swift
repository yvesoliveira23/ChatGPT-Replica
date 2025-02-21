import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - UIApplicationDelegate
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupRootViewController()
        return true
    }

    // MARK: - Private Methods
    private func setupRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let chatViewController = ChatViewController()
        window?.rootViewController = chatViewController
        window?.makeKeyAndVisible()
    }
}
