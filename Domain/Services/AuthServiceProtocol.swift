// AuthServiceProtocol.swift
// QuietJournal — Domain/Interfaces

import Foundation

protocol AuthServiceProtocol {

    var currentUserID: String? { get }

    func register(email: String, password: String) async throws -> String
    
    func login(email: String, password: String) async throws -> String
    
    func logout() throws
}
