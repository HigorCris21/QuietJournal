// Presentation/Home/HomeViewModel.swift
// QuietJournal — Presentation/Home

import Foundation

final class HomeViewModel: HomeViewModelProtocol {

    // MARK: - Callbacks

    var onEntriesUpdated: (([EntryDisplayModel]) -> Void)?
    var onError:          ((String) -> Void)?
    var onLogout:         (() -> Void)?
    var onNewEntry:       (() -> Void)?
    var onEditEntry:      ((JournalEntry) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - State
    private var entries: [JournalEntry] = []
    private(set) var displayEntries: [EntryDisplayModel] = []

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

    func selectEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }
        onEditEntry?(entries[index])
    }

    func deleteEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }
        let entry = entries[index]

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
                self?.entries        = entries
                self?.displayEntries = entries.map { Self.map($0) }

                self?.onEntriesUpdated?(self?.displayEntries ?? [])
                self?.onLoadingChanged?(false)

            case .failure:
                self?.onLoadingChanged?(false)
                self?.onError?("Erro ao carregar entradas.")
            }
        }
    }

    // MARK: - Mapping

    //mudar o visual da célula =
    
    private static func map(_ entry: JournalEntry) -> EntryDisplayModel {
        return EntryDisplayModel(
            title:    "\(entry.mood.emoji)  \(entry.title)",
            subtitle: AppConstants.Formatters.entryDate.string(from: entry.createdAt),
            accessory: entry.mood.emoji
        )
    }
}
