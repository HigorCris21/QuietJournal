// Presentation/Home/HomeViewModel.swift
// QuietJournal — Presentation/Home

import Foundation

final class HomeViewModel: HomeViewModelProtocol {

    // MARK: - Callbacks

    var onEntriesUpdated: (([JournalEntry]) -> Void)?
    var onError:          ((String) -> Void)?
    var onLogout:         (() -> Void)?
    var onNewEntry:       (() -> Void)?
    var onEditEntry:      ((JournalEntry) -> Void)?

    // Callback que avisa a ViewController para ligar/desligar o spinner
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - State

    private(set) var entries: [JournalEntry] = []

    // MARK: - Dependencies

    private let journalService: JournalServiceProtocol
    private let authService:    AuthServiceProtocol
    private let uid:            String

    // MARK: - Init

    init(journalService: JournalServiceProtocol,
         authService:    AuthServiceProtocol,
         uid:            String) {
        self.journalService = journalService
        self.authService    = authService
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
        do {
            try authService.logout()
            journalService.stopListening()
            onLogout?()
        } catch {
            onError?("Não foi possível encerrar a sessão. Tente novamente.")
        }
    }

    // MARK: - Private

    private func fetchEntries() {
        onLoadingChanged?(true)

        journalService.fetchEntries(for: uid) { [weak self] result in
            switch result {
            case .success(let entries):
                self?.entries = entries
                // Dados chegam ANTES do spinner parar
                self?.onEntriesUpdated?(entries)
                self?.onLoadingChanged?(false)
            case .failure:
                self?.onLoadingChanged?(false)
                self?.onError?("Erro ao carregar entradas.")
            }
        }
    }
}
