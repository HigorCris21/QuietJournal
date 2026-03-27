// Presentation/Auth/Login/LoginViewModel.swift
// QuietJournal — Presentation/Auth

import Foundation

final class LoginViewModel {

    // MARK: - Callbacks para a ViewController

    var onLoginSuccess:   (() -> Void)?
    var onRegisterTapped: (() -> Void)?
    var onError:          ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Init

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    func login(email: String, password: String) {

        guard !email.isEmpty, !password.isEmpty else {
            onError?("Preencha todos os campos.")
            return
        }

        guard email.isValidEmail else {
            onError?("Digite um e-mail válido.")
            return
        }

        onLoadingChanged?(true)

        authService.login(email: email, password: password) { [weak self] result in
            self?.onLoadingChanged?(false)

            switch result {
            case .success:
                self?.onLoginSuccess?()

            case .failure(let error):                
                let message = (error as? AuthError)?.localizedDescription
                    ?? AppConstants.Strings.Auth.errorUnknown
                self?.onError?(message)
            }
        }
    }

    func registerTapped() {
        onRegisterTapped?()
    }
}
