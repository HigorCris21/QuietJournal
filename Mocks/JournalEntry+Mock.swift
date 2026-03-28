// QuietJournalTests/Mocks/JournalEntry+Mock.swift

@testable import QuietJournal
import Foundation

extension JournalEntry {

    // Entrada padrão para testes — todos os campos têm valor sensato
    // Parâmetros opcionais: só passe o que precisa mudar no teste
    static func mock(
        id:        String = "id-mock",
        uid:       String = "uid-mock",
        title:     String = "Título mock",
        body:      String = "Conteúdo mock",
        mood:      Mood   = .neutral,
        createdAt: Date   = Date(),
        updatedAt: Date   = Date()
    ) -> JournalEntry {
        return JournalEntry(
            id:        id,
            uid:       uid,
            title:     title,
            body:      body,
            mood:      mood,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
