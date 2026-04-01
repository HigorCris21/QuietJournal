import Foundation

final class EntryViewModel {

    var onSaved: (() -> Void)?
    var onCancelled: (() -> Void)?
    var onError: ((EntryError) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    private let existingEntry: JournalEntry?
    private let journalService: JournalWriteServiceProtocol
    private let uid: String

    var isEditing: Bool {
        existingEntry != nil
    }

    var initialTitle: String {
        existingEntry?.title ?? ""
    }

    var initialBody: String {
        existingEntry?.body ?? ""
    }

    var initialMood: Mood {
        existingEntry?.mood ?? .neutral
    }

    init(journalService: JournalWriteServiceProtocol,
         uid: String,
         entry: JournalEntry?) {

        self.journalService = journalService
        self.uid = uid
        self.existingEntry = entry
    }

    func save(title: String, body: String, mood: Mood) {

        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?(.emptyTitle)
            return
        }

        onLoadingChanged?(true)

        Task {
            do {
                if let existing = existingEntry {
                    try await update(existing: existing, title: title, body: body, mood: mood)
                } else {
                    try await create(title: title, body: body, mood: mood)
                }

                onLoadingChanged?(false)
                onSaved?()

            } catch {
                onLoadingChanged?(false)
                onError?(.saveFailed)
            }
        }
    }

    func cancel() {
        onCancelled?()
    }

    private func create(title: String, body: String, mood: Mood) async throws {

        let now = Date()

        let entry = JournalEntry(
            id: UUID().uuidString,
            uid: uid,
            title: title,
            body: body,
            mood: mood,
            createdAt: now,
            updatedAt: now
        )

        try await journalService.createEntry(entry)
    }

    private func update(existing: JournalEntry,
                        title: String,
                        body: String,
                        mood: Mood) async throws {

        var updated = existing
        updated.title = title
        updated.body = body
        updated.mood = mood
        updated.updatedAt = Date()

        try await journalService.updateEntry(updated)
    }
}
