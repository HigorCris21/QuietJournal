import Foundation

final class UpdateEntryUseCase {

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute(_ entry: JournalEntry) async throws {

        let trimmedTitle = entry.title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryError.emptyTitle
        }

        var updated = entry
        updated.title = trimmedTitle
        updated.body = entry.body.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.updatedAt = Date()

        try await repository.updateEntry(updated)
    }
}
