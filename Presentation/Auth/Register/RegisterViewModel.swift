// Presentation/Auth/Register/RegisterViewModel.swift
// QuietJournal — Presentation/Auth

import Foundation

final class RegisterViewModel {

    // MARK: - Callbacks para a ViewController

    var onRegisterSuccess: (() -> Void)?
    var onBackTapped:      (() -> Void)?
    var onError:           ((String) -> Void)?
    var onLoadingChanged:  ((Bool) -> Void)?

    // MARK: - Dependencies

    private let authService: AuthServiceProtocol

    // MARK: - Init

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    func register(email: String, password: String, confirmPassword: String) {

        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            onError?("Preencha todos os campos.")
            return
        }

        guard email.isValidEmail else {
            onError?("Digite um e-mail válido.")
            return
        }

        guard password == confirmPassword else {
            onError?("As senhas não coincidem.")
            return
        }

        guard password.count >= 6 else {
            onError?("A senha deve ter pelo menos 6 caracteres.")
            return
        }

        onLoadingChanged?(true)

        authService.register(email: email, password: password) { [weak self] result in
            self?.onLoadingChanged?(false)

            switch result {
            case .success:
                self?.onRegisterSuccess?()

            case .failure(let error):
                let message = (error as? AuthError)?.localizedDescription
                    ?? AppConstants.Strings.Auth.errorUnknown
                self?.onError?(message)
            }
        }
    }

    func backTapped() {
        onBackTapped?()
    }
}
