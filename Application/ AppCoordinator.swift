//
//  AppCoordinator.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 10/03/26.
//

import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let navigationController: UINavigationController

    // Protocolos — nunca as implementações concretas
    private let authService: AuthServiceProtocol
    private let journalService: JournalServiceProtocol

    // MARK: - Init

    init(window: UIWindow,
         authService: AuthServiceProtocol,
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

        // Quando o login for concluído, AuthCoordinator avisa o AppCoordinator
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

        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            journalService: journalService,
            uid: uid
        )

        // Quando o logout for executado, HomeCoordinator avisa o AppCoordinator
        homeCoordinator.onLogout = { [weak self] in
            self?.removeChild(homeCoordinator)
            self?.showAuth()
        }

        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}
