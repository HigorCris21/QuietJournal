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

        // MARK: - Firebase
        FirebaseApp.configure()

        // MARK: - Window
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return true
        }

        let window = UIWindow(windowScene: scene)
        self.window = window

        // MARK: - Services

        let authService = AuthService()
        let journalService = JournalService()

        // 🔥 MESMA INSTÂNCIA, DUAS ABSTRAÇÕES
        let journalReadService: JournalReadServiceProtocol = journalService
        let journalWriteService: JournalWriteServiceProtocol = journalService

        // MARK: - Coordinator

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
