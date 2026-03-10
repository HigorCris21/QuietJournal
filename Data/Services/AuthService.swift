// Data/Services/AuthService.swift
// QuietJournal — Data/Services

import Foundation
import FirebaseAuth

// Implementação concreta do contrato AuthServiceProtocol.
// É aqui que o Firebase Auth é usado de verdade.

final class AuthService: AuthServiceProtocol {

    // MARK: - Properties

    // Singleton do Firebase Auth — gerencia sessão, tokens e estado do usuário
    private let auth = Auth.auth()

    // MARK: - currentUserID

    // Propriedade computada: consulta o Firebase se há sessão ativa no momento
    var currentUserID: String? {
        return auth.currentUser?.uid
    }

    // MARK: - Register

    func register(email: String,
                  password: String,
                  completion: @escaping (Result<String, Error>) -> Void) {

        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            // Garante que o completion sempre volta na main thread
            // evitando crashes ao atualizar a UI
            DispatchQueue.main.async {

                // Cenário 1: Firebase retornou um erro — mapeamos para AuthError
                if let error = error {
                    completion(.failure(self?.mapError(error) ?? AuthError.unknown))
                    return
                }

                // Cenário 2: Sucesso — extraímos o UID do usuário criado
                if let uid = result?.user.uid {
                    completion(.success(uid))
                    return
                }

                // Cenário 3: Nem erro nem resultado — estado inválido
                completion(.failure(AuthError.unknown))
            }
        }
    }

    // MARK: - Login

    func login(email: String,
               password: String,
               completion: @escaping (Result<String, Error>) -> Void) {

        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {

                if let error = error {
                    completion(.failure(self?.mapError(error) ?? AuthError.unknown))
                    return
                }

                if let uid = result?.user.uid {
                    completion(.success(uid))
                    return
                }

                completion(.failure(AuthError.unknown))
            }
        }
    }

    // MARK: - Logout

    // Não é assíncrono — Firebase só limpa o token local em memória
    func logout() throws {
        try auth.signOut()
    }

    // MARK: - Private Helpers

    // Converte erros brutos do Firebase em AuthError do Domain.
    // Isso garante que nenhuma camada acima conhece FirebaseAuth.
    private func mapError(_ error: Error) -> AuthError {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .wrongPassword, .invalidEmail:  return .invalidCredentials
        case .userNotFound:                  return .userNotFound
        case .networkError:                  return .networkError
        case .emailAlreadyInUse:             return .emailAlreadyInUse
        default:                             return .unknown
        }
    }
}
