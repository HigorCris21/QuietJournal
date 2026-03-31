// Presentation/Entry/EntryViewModel.swift

import Foundation

final class EntryViewModel {

    // MARK: - Callbacks

    var onSaved:     (() -> Void)?
    var onCancelled: (() -> Void)?
    var onError:     ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - State

    private let existingEntry: JournalEntry?
    private let journalService: JournalWriteServiceProtocol
    private let authService: AuthServiceProtocol

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

    init(journalService: JournalWriteServiceProtocol,
         authService: AuthServiceProtocol,
         entry: JournalEntry?) {

        self.journalService = journalService
        self.authService    = authService
        self.existingEntry  = entry
    }

    // MARK: - Actions

    func save(title: String, body: String, mood: Mood) {

        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("O título não pode estar vazio.")
            return
        }

        guard let uid = authService.currentUserID else {
            onError?("Usuário não autenticado.")
            return
        }

        onLoadingChanged?(true)

        Task {
            do {
                if let existing = existingEntry {
                    try await update(existing: existing, title: title, body: body, mood: mood)
                } else {
                    try await create(uid: uid, title: title, body: body, mood: mood)
                }

                onLoadingChanged?(false)
                onSaved?()

            } catch {
                onLoadingChanged?(false)
                onError?("Não foi possível salvar a entrada.")
            }
        }
    }

    func cancel() {
        onCancelled?()
    }

    // MARK: - Private

    private func create(uid: String,
                        title: String,
                        body: String,
                        mood: Mood) async throws {

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

        var updated       = existing
        updated.title     = title
        updated.body      = body
        updated.mood      = mood
        updated.updatedAt = Date()

        try await journalService.updateEntry(updated)
    }
}
