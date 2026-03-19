// JournalEntry.swift
// QuietJournal — Domain/Models

import Foundation
import FirebaseFirestore

//Rrepresenta uma entrada (página) do diário.

struct JournalEntry {
    let id: String          // ID único gerado pelo Firestore
    let uid: String         // ID do usuário dono da entrada (Firebase Auth)
    var title: String       // Título da entrada
    var body: String        // Texto livre do dia
    var mood: Mood          // Humor do dia (enum Mood)
    let createdAt: Date     // Data de criação — imutável após criada
    var updatedAt: Date     // Data da última edição
}

// MARK: - Firestore Conversion

extension JournalEntry {

    // Converte a struct para Dictionary para salvar no Firestore
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

    // Converte um Document do Firestore de volta para a struct
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
