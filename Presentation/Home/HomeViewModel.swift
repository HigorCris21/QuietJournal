// Presentation/Home/HomeViewModel.swift
// QuietJournal — Presentation/Home

import Foundation

final class HomeViewModel {

    // MARK: - Callbacks

    var onEntriesUpdated: (([JournalEntry]) -> Void)?
    var onError:          ((String) -> Void)?
    var onLogout:         (() -> Void)?
    var onNewEntry:       (() -> Void)?
    var onEditEntry:      ((JournalEntry) -> Void)?

    // MARK: - State

    private(set) var entries: [JournalEntry] = []

    // MARK: - Dependencies

    private let journalService: JournalServiceProtocol
    private let uid: String

    // MARK: - Init

    init(journalService: JournalServiceProtocol, uid: String) {
        self.journalService = journalService
        self.uid            = uid
    }

    // MARK: - Actions

    func viewDidLoad() {
        fetchEntries()
    }

    func newEntryTapped() {
        onNewEntry?()
    }

    func editEntry(_ entry: JournalEntry) {
        onEditEntry?(entry)
    }

    func deleteEntry(_ entry: JournalEntry) {
        journalService.deleteEntry(id: entry.id, for: uid) { [weak self] result in
            if case .failure = result {
                self?.onError?("Não foi possível deletar a entrada.")
            }
        }
    }

    func logout() {
        onLogout?()
    }

    // MARK: - Private

    private func fetchEntries() {
        journalService.fetchEntries(for: uid) { [weak self] result in
            switch result {
            case .success(let entries):
                self?.entries = entries
                self?.onEntriesUpdated?(entries)
            case .failure:
                self?.onError?("Erro ao carregar entradas.")
            }
        }
    }
}
