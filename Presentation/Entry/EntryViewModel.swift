// Presentation/Entry/EntryViewModel.swift
// QuietJournal — Presentation/Entry

import Foundation

final class EntryViewModel {

    // MARK: - Callbacks

    var onSaved:     (() -> Void)?
    var onCancelled: (() -> Void)?
    var onError:     ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - State

    // Se entry for nil, estamos criando. Se não, editando.
    private let existingEntry: JournalEntry?
    private let journalService: JournalServiceProtocol
    private let uid: String

    // Modo da tela — usado pela ViewController para ajustar o título
    var isEditing: Bool { existingEntry != nil }

    // Valores iniciais para preencher os campos na edição
    var initialTitle: String { existingEntry?.title ?? "" }
    var initialBody:  String { existingEntry?.body  ?? "" }
    var initialMood:  Mood   { existingEntry?.mood  ?? .neutral }

    // MARK: - Init

    init(journalService: JournalServiceProtocol,
         uid: String,
         entry: JournalEntry?) {
        self.journalService = journalService
        self.uid            = uid
        self.existingEntry  = entry
    }

    // MARK: - Actions

    func save(title: String, body: String, mood: Mood) {

        // Validação — título obrigatório
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("O título não pode estar vazio.")
            return
        }

        onLoadingChanged?(true)

        if let existing = existingEntry {
            update(existing: existing, title: title, body: body, mood: mood)
        } else {
            create(title: title, body: body, mood: mood)
        }
    }

    func cancel() {
        onCancelled?()
    }

    // MARK: - Private

    private func create(title: String, body: String, mood: Mood) {
        let now   = Date()
        let entry = JournalEntry(
            id:        UUID().uuidString,  // ID único gerado localmente
            uid:       uid,
            title:     title,
            body:      body,
            mood:      mood,
            createdAt: now,
            updatedAt: now
        )

        journalService.createEntry(entry) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success:       self?.onSaved?()
            case .failure:       self?.onError?("Não foi possível salvar a entrada.")
            }
        }
    }

    private func update(existing: JournalEntry, title: String, body: String, mood: Mood) {
        // Cria uma cópia com os campos editados e updatedAt atualizado
        var updated          = existing
        updated.title        = title
        updated.body         = body
        updated.mood         = mood
        updated.updatedAt    = Date()

        journalService.updateEntry(updated) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success:   self?.onSaved?()
            case .failure:   self?.onError?("Não foi possível atualizar a entrada.")
            }
        }
    }
}
