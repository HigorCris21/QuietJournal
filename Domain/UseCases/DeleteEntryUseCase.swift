import Foundation

final class DeleteEntryUseCase {

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute(entryId: String, userId: String) async throws {

        // (opcional) validação simples
        guard !entryId.isEmpty else {
            throw HomeError.deleteFailed
        }

        try await repository.deleteEntry(
            entryId: entryId,
            userId: userId
        )
    }
}
