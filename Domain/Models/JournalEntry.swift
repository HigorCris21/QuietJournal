import Foundation

struct JournalEntry {
    let id: String
    let uid: String
    var title: String
    var body: String
    var mood: Mood
    let createdAt: Date
    var updatedAt: Date
}
