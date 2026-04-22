//
//  CreateEntryUseCase.swift
//  QuietJournal
//

import Foundation

final class CreateEntryUseCase {

    // MARK: - Dependencies

    private let repository: JournalRepositoryProtocol

    // MARK: - Init

    init(repository: JournalRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute(
        title: String,
        body: String,
        mood: Mood,
        uid: String
    ) async throws {

        // 1. Validação (REGRA DE NEGÓCIO)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            throw EntryError.emptyTitle
        }

        // 2. Normalização (opcional, mas profissional)
        let normalizedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)

        // 3. Regra temporal (centralizada)
        let now = Date()

        // 4. Criação da entidade (DOMÍNIO)
        let entry = JournalEntry(
            id: UUID().uuidString,
            uid: uid,
            title: trimmedTitle,
            body: normalizedBody,
            mood: mood,
            createdAt: now,
            updatedAt: now
        )

        // 5. Persistência via repository (NÃO service direto)
        try await repository.createEntry(entry)
    }
}
