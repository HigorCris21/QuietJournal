import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    private let diContainer = AppDIContainer()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //inicializa Firebase primeiro
        FirebaseApp.configure()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let coordinator = AppCoordinator(
            window: window,
            diContainer: diContainer
        )

        self.appCoordinator = coordinator
        coordinator.start()

        return true
    }
}
