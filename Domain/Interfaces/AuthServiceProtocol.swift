// AuthServiceProtocol.swift
// QuietJournal — Domain/Interfaces

import Foundation

// Contrato que define o que qualquer serviço de autenticação deve saber fazer.
// A ViewModel depende deste protocolo, nunca do Firebase diretamente. (SOLID - D)

protocol AuthServiceProtocol {

    // Retorna o ID do usuário logado, ou nil se não houver sessão ativa
    var currentUserID: String? { get }

    // Cadastra um novo usuário com email e senha
    func register(email: String,
                  password: String,
                  completion: @escaping (Result<String, Error>) -> Void)

    // Faz login com email e senha
    func login(email: String,
               password: String,
               completion: @escaping (Result<String, Error>) -> Void)

    // Encerra a sessão do usuário atual
    func logout() throws
}
