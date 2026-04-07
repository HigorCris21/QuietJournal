import Foundation
import FirebaseAuth

final class AuthService: AuthServiceProtocol {

    private let auth = Auth.auth()

    var currentUserID: String? {
        return auth.currentUser?.uid
    }

    // MARK: - Register

    func register(email: String, password: String) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in

            auth.createUser(withEmail: email, password: password) { [weak self] result, error in

                if let error = error {
                    continuation.resume(throwing: self?.mapError(error) ?? AuthError.unknown)
                    return
                }

                if let uid = result?.user.uid {
                    continuation.resume(returning: uid)
                    return
                }

                continuation.resume(throwing: AuthError.unknown)
            }
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in

            auth.signIn(withEmail: email, password: password) { [weak self] result, error in

                if let error = error {
                    continuation.resume(throwing: self?.mapError(error) ?? AuthError.unknown)
                    return
                }

                if let uid = result?.user.uid {
                    continuation.resume(returning: uid)
                    return
                }

                continuation.resume(throwing: AuthError.unknown)
            }
        }
    }

    // MARK: - Logout

    func logout() throws {
        try auth.signOut()
    }

    // MARK: - Private

    private func mapError(_ error: Error) -> AuthError {
        let code = AuthErrorCode(rawValue: (error as NSError).code)

        switch code {
        case .wrongPassword, .invalidEmail: return .invalidCredentials
        case .userNotFound: return .userNotFound
        case .networkError: return .networkError
        case .emailAlreadyInUse: return .emailAlreadyInUse
        default: return .unknown
        }
    }
}
