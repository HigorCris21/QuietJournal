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

        // Validação local antes de chamar o Firebase
        guard !email.isEmpty, !password.isEmpty else {
            onError?("Preencha todos os campos.")
            return
        }

        onLoadingChanged?(true)

        authService.login(email: email, password: password) { [weak self] result in
            self?.onLoadingChanged?(false)

            switch result {
            case .success:
                self?.onLoginSuccess?()

            case .failure(let error):
                self?.onError?(self?.errorMessage(for: error) ?? AppConstants.Strings.Auth.errorUnknown)
            }
        }
    }

    func registerTapped() {
        onRegisterTapped?()
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
