import Foundation

final class LoginViewModel {

    // MARK: - Callbacks

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

        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await authService.login(email: email, password: password)

                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onLoginSuccess?()
                }

            } catch {
                let message = (error as? AuthError)?.localizedDescription
                    ?? AppConstants.Strings.Auth.errorUnknown

                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onError?(message)
                }
            }
        }
    }

    func registerTapped() {
        onRegisterTapped?()
    }
}
