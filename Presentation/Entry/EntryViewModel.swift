import Foundation

final class EntryViewModel {

    // MARK: - Callbacks

    var onSaved: (() -> Void)?
    var onCancelled: (() -> Void)?
    var onError: ((EntryError) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - Dependencies

    private let createEntryUseCase: CreateEntryUseCase
    private let updateEntryUseCase: UpdateEntryUseCase
    private let uid: String

    private let existingEntry: JournalEntry?

    // MARK: - Computed

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

    // MARK: - Init

    init(createEntryUseCase: CreateEntryUseCase,
         updateEntryUseCase: UpdateEntryUseCase,
         uid: String,
         entry: JournalEntry?) {

        self.createEntryUseCase = createEntryUseCase
        self.updateEntryUseCase = updateEntryUseCase
        self.uid = uid
        self.existingEntry = entry
    }

    // MARK: - Actions

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

    // MARK: - Private
    
    private func create(title: String, body: String, mood: Mood) async throws {
        try await createEntryUseCase.execute(
            title: title,
            body: body,
            mood: mood,
            uid: uid
        )
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

        try await updateEntryUseCase.execute(updated)
    }
}
