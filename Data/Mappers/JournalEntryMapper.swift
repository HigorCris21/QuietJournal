import Foundation
import FirebaseFirestore

struct JournalEntryMapper {

    static func toFirestore(_ entry: JournalEntry) -> [String: Any] {
        return [
            "uid": entry.uid,
            "title": entry.title,
            "body": entry.body,
            "mood": entry.mood.rawValue,
            "createdAt": Timestamp(date: entry.createdAt),
            "updatedAt": Timestamp(date: entry.updatedAt)
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> JournalEntry? {
        guard
            let uid       = data["uid"] as? String,
            let title     = data["title"] as? String,
            let body      = data["body"] as? String,
            let moodRaw   = data["mood"] as? String,
            let mood      = Mood(rawValue: moodRaw),
            let createdTs = data["createdAt"] as? Timestamp,
            let updatedTs = data["updatedAt"] as? Timestamp
        else {
            return nil
        }

        return JournalEntry(
            id: id,
            uid: uid,
            title: title,
            body: body,
            mood: mood,
            createdAt: createdTs.dateValue(),
            updatedAt: updatedTs.dateValue()
        )
    }
}


