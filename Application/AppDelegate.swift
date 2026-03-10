//
//  AppDelegate.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 05/03/26.
//
import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        // Cria a janela principal do app
        window = UIWindow(frame: UIScreen.main.bounds)

        // Injeta os serviços no AppCoordinator
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
