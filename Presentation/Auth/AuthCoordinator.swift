// Presentation/Auth/AuthCoordinator.swift
// QuietJournal — Presentation/Auth

import UIKit

final class AuthCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let authService: AuthServiceProtocol

    // Callback para avisar o AppCoordinator que auth foi concluída
    var onAuthCompleted: (() -> Void)?

    // MARK: - Init

    init(navigationController: UINavigationController,
         authService: AuthServiceProtocol) {
        self.navigationController = navigationController
        self.authService          = authService
    }

    // MARK: - Start

    func start() {
        showLogin()
    }

    // MARK: - Flows

    private func showLogin() {
        let viewModel          = LoginViewModel(authService: authService)
        viewModel.onLoginSuccess  = { [weak self] in self?.onAuthCompleted?() }
        viewModel.onRegisterTapped = { [weak self] in self?.showRegister() }

        let vc = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showRegister() {
        let viewModel             = RegisterViewModel(authService: authService)
        viewModel.onRegisterSuccess = { [weak self] in self?.onAuthCompleted?() }
        viewModel.onBackTapped      = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        let vc = RegisterViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
