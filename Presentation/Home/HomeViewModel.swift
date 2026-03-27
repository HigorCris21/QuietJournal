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
    private let uid:            String

   //authService entra como dependência.
    private let authService: AuthServiceProtocol

    // MARK: - Init

    //AuthService agora faz parte do contrato do init.
   
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

    // Logout agora executa as 3 etapas na ordem correta:
    //
   
    func logout() {
        do {
            try authService.logout()        // 1. Firebase encerra sessão
            journalService.stopListening()  // 2. Listener do Firestore encerrado
            onLogout?()                     // 3. Coordinator troca a tela
        } catch {
            // Se o Firebase retornar erro no logout (raro, mas possível em falha de rede),
            onError?("Não foi possível encerrar a sessão. Tente novamente.")
        }
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
