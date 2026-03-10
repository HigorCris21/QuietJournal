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

        // Validação 1 — campos vazios
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            onError?("Preencha todos os campos.")
            return
        }

        // Validação 2 — senhas coincidem
        guard password == confirmPassword else {
            onError?("As senhas não coincidem.")
            return
        }

        // Validação 3 — senha fraca
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
                self?.onError?(self?.errorMessage(for: error) ?? AppConstants.Strings.Auth.errorUnknown)
            }
        }
    }

    func backTapped() {
        onBackTapped?()
    }

    // MARK: - Private Helpers

    private func errorMessage(for error: Error) -> String {
        guard let authError = error as? AuthError else {
            return AppConstants.Strings.Auth.errorUnknown
        }

        switch authError {
        case .invalidCredentials: return AppConstants.Strings.Auth.errorInvalidCredentials
        case .userNotFound:       return AppConstants.Strings.Auth.errorUserNotFound
        case .emailAlreadyInUse:  return AppConstants.Strings.Auth.errorEmailInUse
        case .networkError:       return AppConstants.Strings.Auth.errorNetwork
        case .unknown:            return AppConstants.Strings.Auth.errorUnknown
        }
    }
}
