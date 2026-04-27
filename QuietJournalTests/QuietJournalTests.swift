// QuietJournalTests/LoginViewModelTests.swift

import XCTest
@testable import QuietJournal

final class LoginViewModelTests: XCTestCase {

    // MARK: - Setup

    private var authService: MockAuthService!
    private var sut: LoginViewModel!   // sut = System Under Test — convenção de testes

    override func setUp() {
        super.setUp()
        authService = MockAuthService()
        sut         = LoginViewModel(authService: authService)
    }

    override func tearDown() {
        authService = nil
        sut         = nil
        super.tearDown()
    }

    // MARK: - Campos vazios

    func test_login_emailVazio_deveDispararErro() {
        // Arrange
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }

        // Act
        sut.login(email: "", password: "123456")

        // Assert
        XCTAssertEqual(errorMessage, "Preencha todos os campos.")
        XCTAssertFalse(authService.loginCalled) // serviço NÃO deve ser chamado
    }

    func test_login_senhaVazia_deveDispararErro() {
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }

        sut.login(email: "email@teste.com", password: "")

        XCTAssertEqual(errorMessage, "Preencha todos os campos.")
        XCTAssertFalse(authService.loginCalled)
    }

    // MARK: - Email inválido

    func test_login_emailInvalido_deveDispararErro() {
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }

        sut.login(email: "emailsemarroba", password: "123456")

        XCTAssertEqual(errorMessage, "Digite um e-mail válido.")
        XCTAssertFalse(authService.loginCalled)
    }

    // MARK: - Sucesso

    func test_login_credenciaisValidas_deveDispararOnLoginSuccess() {
        // Arrange
        authService.loginResult = .success("uid-real")
        let exp = expectation(description: "onLoginSuccess chamado")
        sut.onLoginSuccess = { exp.fulfill() }

        // Act
        sut.login(email: "email@teste.com", password: "123456")

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(authService.loginCalled)
    }

    // MARK: - Falha do serviço

    func test_login_credenciaisInvalidas_deveDispararErroCorreto() {
        // Arrange — serviço vai retornar credenciais inválidas
        authService.loginResult = .failure(AuthError.invalidCredentials)
        let exp = expectation(description: "onError chamado")
        var errorMessage: String?
        sut.onError = {
            errorMessage = $0
            exp.fulfill()
        }

        // Act
        sut.login(email: "email@teste.com", password: "senhaerrada")

        wait(for: [exp], timeout: 1.0)

        // Assert — mensagem vem do AuthError.localizedDescription
        XCTAssertEqual(errorMessage, AppConstants.Strings.Auth.errorInvalidCredentials)
    }

    // MARK: - Loading

    func test_login_deveDispararLoadingTrue_antesDeAutenticar() {
        // Arrange
        var loadingStates: [Bool] = []
        let exp = expectation(description: "loading terminou")
        sut.onLoadingChanged = {
            loadingStates.append($0)
            if $0 == false {
                exp.fulfill()
            }
        }

        // Act
        sut.login(email: "email@teste.com", password: "123456")

        wait(for: [exp], timeout: 1.0)

        // Assert — primeiro estado deve ser true (loading ligou), depois false
        XCTAssertEqual(loadingStates.first, true)
        XCTAssertEqual(loadingStates.last,  false)
    }
}

private final class MockAuthService: AuthServiceProtocol {

    var currentUserID: String?

    var loginResult: Result<String, Error> = .success("uid-mock")
    var registerResult: Result<String, Error> = .success("uid-mock")
    var shouldThrowOnLogout = false

    var loginCalled = false
    var registerCalled = false
    var logoutCalled = false

    func register(email: String, password: String) async throws -> String {
        registerCalled = true
        return try registerResult.get()
    }

    func login(email: String, password: String) async throws -> String {
        loginCalled = true
        return try loginResult.get()
    }

    func logout() throws {
        logoutCalled = true
        if shouldThrowOnLogout {
            throw AuthError.unknown
        }
    }
}
