//
//  AppDIContainer.swift
//  QuietJournal
//

import Foundation

final class AppDIContainer {

    // MARK: - Services

    private lazy var journalReadService: JournalReadServiceProtocol = {
        JournalReadService()
    }()

    private lazy var journalWriteService: JournalWriteServiceProtocol = {
        JournalWriteService()
    }()

    private lazy var authService: AuthServiceProtocol = {
        AuthService()
    }()

    // MARK: - Repository

    private lazy var journalRepository: JournalRepositoryProtocol = {
        JournalRepository(
            readService: journalReadService,
            writeService: journalWriteService
        )
    }()

    // MARK: - UseCases

    func makeGetEntriesUseCase() -> GetEntriesUseCase {
        GetEntriesUseCase(repository: journalRepository)
    }

    func makeCreateEntryUseCase() -> CreateEntryUseCase {
        CreateEntryUseCase(repository: journalRepository)
    }

    func makeUpdateEntryUseCase() -> UpdateEntryUseCase {
        UpdateEntryUseCase(repository: journalRepository)
    }

    func makeDeleteEntryUseCase() -> DeleteEntryUseCase {
        DeleteEntryUseCase(repository: journalRepository)
    }

    func makeAuthService() -> AuthServiceProtocol {
        authService
    }
}
