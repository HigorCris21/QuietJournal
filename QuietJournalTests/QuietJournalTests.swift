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
        var successCalled = false
        sut.onLoginSuccess = { successCalled = true }

        // Act
        sut.login(email: "email@teste.com", password: "123456")

        // Assert
        XCTAssertTrue(successCalled)
        XCTAssertTrue(authService.loginCalled)
    }

    // MARK: - Falha do serviço

    func test_login_credenciaisInvalidas_deveDispararErroCorreto() {
        // Arrange — serviço vai retornar credenciais inválidas
        authService.loginResult = .failure(AuthError.invalidCredentials)
        var errorMessage: String?
        sut.onError = { errorMessage = $0 }

        // Act
        sut.login(email: "email@teste.com", password: "senhaerrada")

        // Assert — mensagem vem do AuthError.localizedDescription
        XCTAssertEqual(errorMessage, AppConstants.Strings.Auth.errorInvalidCredentials)
    }

    // MARK: - Loading

    func test_login_deveDispararLoadingTrue_antesDeAutenticar() {
        // Arrange
        var loadingStates: [Bool] = []
        sut.onLoadingChanged = { loadingStates.append($0) }

        // Act
        sut.login(email: "email@teste.com", password: "123456")

        // Assert — primeiro estado deve ser true (loading ligou), depois false
        XCTAssertEqual(loadingStates.first, true)
        XCTAssertEqual(loadingStates.last,  false)
    }
}
