// Application/AppCoordinator.swift

import UIKit

@MainActor
final class AppCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private var navigationController: UINavigationController?

    private let authService: AuthServiceProtocol
    private let journalReadService: JournalReadServiceProtocol
    private let journalWriteService: JournalWriteServiceProtocol

    // MARK: - Init

    init(window: UIWindow,
         authService: AuthServiceProtocol,
         journalReadService: JournalReadServiceProtocol,
         journalWriteService: JournalWriteServiceProtocol) {

        self.window = window
        self.authService = authService
        self.journalReadService = journalReadService
        self.journalWriteService = journalWriteService
        self.navigationController = UINavigationController()

        window.rootViewController = navigationController
    }

    // MARK: - Start

    func start() {
        if authService.currentUserID != nil {
            showHome()
        } else {
            showAuth()
        }

        window.makeKeyAndVisible()
    }

    // MARK: - Flows

    private func showAuth() {
        let nav = UINavigationController()
        navigationController = nav

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.window.rootViewController = nav
            }
        )

        let authCoordinator = AuthCoordinator(
            navigationController: nav,
            authService: authService
        )

        authCoordinator.onAuthCompleted = { [weak self, weak authCoordinator] in
            guard let self, let authCoordinator else { return }
            self.removeChild(authCoordinator)
            self.showHome()
        }

        addChild(authCoordinator)
        authCoordinator.start()
    }

    private func showHome() {
        guard let uid = authService.currentUserID else {
            showAuth()
            return
        }

        let nav = UINavigationController()
        navigationController = nav

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.window.rootViewController = nav
            }
        )

        let homeCoordinator = HomeCoordinator(
            navigationController: nav,
            journalReadService: journalReadService,
            journalWriteService: journalWriteService,
            authService: authService
        )

        homeCoordinator.onLogout = { [weak self, weak homeCoordinator] in
            guard let self, let homeCoordinator else { return }
            self.removeChild(homeCoordinator)
            self.showAuth()
        }

        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}
