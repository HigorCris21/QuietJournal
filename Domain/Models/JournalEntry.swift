// JournalEntry.swift
// QuietJournal — Domain/Models
import Foundation
import FirebaseFirestore

// Representa uma entrada (página) do diário.
struct JournalEntry {
    let id:        String
    let uid:       String
    var title:     String
    var body:      String
    var mood:      Mood
    let createdAt: Date
    var updatedAt: Date
}

// MARK: - Firestore Conversion

extension JournalEntry {

    /// Converte o modelo de domínio para formato aceito pelo Firestore
    func toFirestore() -> [String: Any] {
        return [
            "uid":       uid,
            "title":     title,
            "body":      body,
            "mood":      mood.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }

    /// Converte dados do Firestore para o modelo de domínio
    static func fromFirestore(id: String, data: [String: Any]) -> JournalEntry? {
        guard
            let uid       = data["uid"]       as? String,
            let title     = data["title"]     as? String,
            let body      = data["body"]      as? String,
            let moodRaw   = data["mood"]      as? String,
            let mood      = Mood(rawValue: moodRaw),
            let createdTs = data["createdAt"] as? Timestamp,
            let updatedTs = data["updatedAt"] as? Timestamp
        else { return nil }

        return JournalEntry(
            id:        id,
            uid:       uid,
            title:     title,
            body:      body,
            mood:      mood,
            createdAt: createdTs.dateValue(),
            updatedAt: updatedTs.dateValue()
        )
    }
}
