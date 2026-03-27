// Application/AppDelegate.swift
// QuietJournal — Application

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        // UIWindow criada a partir da cena ativa
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return true
        }

        window = UIWindow(windowScene: scene)

        let authService    = AuthService()
        let journalService = JournalService()

        appCoordinator = AppCoordinator(
            window: window!,
            authService: authService,
            journalService: journalService
        )

        appCoordinator?.start()
        window?.makeKeyAndVisible()

        return true
    }
}
