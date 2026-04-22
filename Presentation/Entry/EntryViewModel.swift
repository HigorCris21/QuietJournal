import Foundation

final class EntryViewModel {

    // MARK: - Dependencies

    private let createEntryUseCase: CreateEntryUseCase
    private let updateEntryUseCase: UpdateEntryUseCase

    // MARK: - State

    private let uid: String
    private let entry: JournalEntry?

    // MARK: - Outputs

    var onSaved: (() -> Void)?
    var onCancelled: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init

    init(
        createEntryUseCase: CreateEntryUseCase,
        updateEntryUseCase: UpdateEntryUseCase,
        uid: String,
        entry: JournalEntry?
    ) {
        self.createEntryUseCase = createEntryUseCase
        self.updateEntryUseCase = updateEntryUseCase
        self.uid = uid
        self.entry = entry
    }

    // MARK: - Derived State

    var isEditing: Bool {
        entry != nil
    }

    var initialTitle: String {
        entry?.title ?? ""
    }

    var initialBody: String {
        entry?.body ?? ""
    }

    var initialMood: Mood {
        entry?.mood ?? .neutral
    }

    // MARK: - Actions

    func save(title: String, body: String, mood: Mood) {

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            onError?("O título não pode estar vazio.")
            return
        }

        onLoadingChanged?(true)

        Task {
            do {

                if let entry {

                    // UPDATE (usa UseCase que recebe JournalEntry)
                    var updated = entry
                    updated.title = trimmedTitle
                    updated.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
                    updated.mood = mood
                    updated.updatedAt = Date()

                    try await updateEntryUseCase.execute(updated)

                } else {

                    // CREATE (usa UseCase com parâmetros separados)
                    try await createEntryUseCase.execute(
                        title: trimmedTitle,
                        body: body,
                        mood: mood,
                        uid: uid
                    )
                }

                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onSaved?()
                }

            } catch {
                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onError?("Erro ao salvar entrada.")
                }
            }
        }
    }

    func cancel() {
        onCancelled?()
    }
}
