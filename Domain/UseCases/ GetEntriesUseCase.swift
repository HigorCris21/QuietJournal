//
//  GetEntriesUseCase.swift
//  QuietJournal
//

import Foundation

final class GetEntriesUseCase {

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute(userId: String) -> AsyncStream<[JournalEntry]> {
        return repository.observeEntries(userId: userId)
    }
}
