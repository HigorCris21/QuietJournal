import Foundation

struct JournalEntry: Hashable {

    let id: String
    let uid: String
    var title: String
    var body: String
    var mood: Mood
    let createdAt: Date
    var updatedAt: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id
    }
}
