// Domain/Errors/AuthError.swift
// QuietJournal — Domain/Errors

import Foundation

// Erros de autenticação do ponto de vista do Domínio.
// A ViewModel conhece apenas estes casos — nunca os erros brutos do Firebase.

enum AuthError: Error {
    case invalidCredentials  // email ou senha incorretos
    case userNotFound        // usuário não cadastrado
    case emailAlreadyInUse   // tentativa de cadastro com email existente
    case networkError        // sem conexão
    case unknown             // qualquer outro caso
}



