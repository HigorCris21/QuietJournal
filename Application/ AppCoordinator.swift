// Application/AppCoordinator.swift
// QuietJournal — Application

import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let navigationController: UINavigationController

    // Protocolos — nunca as implementações concretas
    private let authService:    AuthServiceProtocol
    private let journalService: JournalServiceProtocol

    // MARK: - Init

    init(window: UIWindow,
         authService:    AuthServiceProtocol,
         journalService: JournalServiceProtocol) {

        self.window               = window
        self.authService          = authService
        self.journalService       = journalService
        self.navigationController = UINavigationController()

        window.rootViewController = navigationController
    }

    // MARK: - Start

    func start() {
        // Verifica sessão ativa no Firebase
        if authService.currentUserID != nil {
            showHome()
        } else {
            showAuth()
        }
    }

    // MARK: - Flows

    private func showAuth() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            authService: authService
        )

        authCoordinator.onAuthCompleted = { [weak self] in
            self?.removeChild(authCoordinator)
            self?.showHome()
        }

        addChild(authCoordinator)
        authCoordinator.start()
    }

    private func showHome() {
        guard let uid = authService.currentUserID else {
            showAuth()
            return
        }

        // AuthService agora é passado para HomeCoordinator.
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            journalService:       journalService,
            authService:          authService,   // ← linha que faltava
            uid:                  uid
        )

        homeCoordinator.onLogout = { [weak self] in
            self?.removeChild(homeCoordinator)
            self?.showAuth()
        }

        addChild(homeCoordinator)
        homeCoordinator.start()
    } 
}
