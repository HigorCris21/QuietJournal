// JournalEntry.swift
// QuietJournal — Domain/Models

import Foundation

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

    func toFirestore() -> [String: Any] {
        return [
            "uid":       uid,
            "title":     title,
            "body":      body,
            "mood":      mood.rawValue,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> JournalEntry? {
        guard
            let uid       = data["uid"]       as? String,
            let title     = data["title"]     as? String,
            let body      = data["body"]      as? String,
            let moodRaw   = data["mood"]      as? String,
            let mood      = Mood(rawValue: moodRaw),
            let createdAt = data["createdAt"] as? Date,
            let updatedAt = data["updatedAt"] as? Date
        else { return nil }

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
