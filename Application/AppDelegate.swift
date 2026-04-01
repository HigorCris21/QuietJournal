import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return true
        }

        let window = UIWindow(windowScene: scene)
        self.window = window

        let authService = AuthService()

        let journalReadService: JournalReadServiceProtocol = JournalReadService()
        let journalWriteService: JournalWriteServiceProtocol = JournalWriteService()

        let coordinator = AppCoordinator(
            window: window,
            authService: authService,
            journalReadService: journalReadService,
            journalWriteService: journalWriteService
        )

        self.appCoordinator = coordinator
        coordinator.start()

        return true
    }
}
