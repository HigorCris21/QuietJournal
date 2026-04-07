//// QuietJournalTests/Mocks/MockAuthService.swift
//
//@testable import QuietJournal
//
//final class MockAuthService: AuthServiceProtocol {
//
//    // MARK: - Estado controlável
//
//    var currentUserID: String? = nil
//
//    // Você define antes do teste o que o serviço vai retornar
//    var loginResult:    Result<String, Error> = .success("uid-mock")
//    var registerResult: Result<String, Error> = .success("uid-mock")
//    var shouldThrowOnLogout = false
//
//    // MARK: - Rastreamento de chamadas
//    // Permite verificar SE o método foi chamado — não só o resultado
//
//    var loginCalled    = false
//    var registerCalled = false
//    var logoutCalled   = false
//
//    // MARK: - AuthServiceProtocol
//
//    func login(email: String,
//               password: String,
//               completion: @escaping (Result<String, Error>) -> Void) {
//        loginCalled = true
//        completion(loginResult)
//    }
//
//    func register(email: String,
//                  password: String,
//                  completion: @escaping (Result<String, Error>) -> Void) {
//        registerCalled = true
//        completion(registerResult)
//    }
//
//    func logout() throws {
//        logoutCalled = true
//        if shouldThrowOnLogout {
//            throw AuthError.unknown
//        }
//    }
//}
