// Domain/Errors/AuthError.swift
// QuietJournal — Domain/Errors

import Foundation

// Erros de autenticação do ponto de vista do Domínio.

enum AuthError: Error {
    case invalidCredentials  // email ou senha incorretos
    case userNotFound        // usuário não cadastrado
    case emailAlreadyInUse   // tentativa de cadastro com email existente
    case networkError        // sem conexão
    case unknown             // qualquer outro caso
}

// MARK: - Mensagem legível para o usuário

extension AuthError {

    // Cada erro sabe se traduzir em mensagem de UI.
    var localizedDescription: String {
        switch self {
        case .invalidCredentials: return AppConstants.Strings.Auth.errorInvalidCredentials
        case .userNotFound:       return AppConstants.Strings.Auth.errorUserNotFound
        case .emailAlreadyInUse:  return AppConstants.Strings.Auth.errorEmailInUse
        case .networkError:       return AppConstants.Strings.Auth.errorNetwork
        case .unknown:            return AppConstants.Strings.Auth.errorUnknown
        }
    }
}
