@MainActor
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

    private let readService: JournalReadServiceProtocol
    private let writeService: JournalWriteServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: - Init

    init(readService: JournalReadServiceProtocol,
         writeService: JournalWriteServiceProtocol,
         authService: AuthServiceProtocol) {

        self.readService  = readService
        self.writeService = writeService
        self.authService  = authService
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        guard let uid = authService.currentUserID else {
            onError?("Usuário não autenticado.")
            return
        }

        observeEntries(uid: uid)
    }

    // MARK: - Actions

    func newEntryTapped() {
        onNewEntry?()
    }

    func selectEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }
        onEditEntry?(entries[index])
    }

    func deleteEntry(at index: Int) {
        guard entries.indices.contains(index) else { return }

        guard let uid = authService.currentUserID else {
            onError?("Usuário não autenticado.")
            return
        }

        let entry = entries[index]

        Task {
            onLoadingChanged?(true)

            do {
                try await writeService.deleteEntry(id: entry.id, for: uid)
            } catch {
                onError?("Não foi possível deletar.")
            }

            onLoadingChanged?(false)
        }
    }

    func logout() {
        do {
            try authService.logout()
            readService.stopObserving()
            onLogout?()
        } catch {
            onError?("Erro ao sair.")
        }
    }

    // MARK: - Private

    private func observeEntries(uid: String) {

        onLoadingChanged?(true)

        readService.observeEntries(
            for: uid,
            onUpdate: { [weak self] (entries: [JournalEntry]) in
                guard let self else { return }

                self.entries = entries
                self.displayEntries = entries.map { Self.map($0) }

                self.onEntriesUpdated?(self.displayEntries)
                self.onLoadingChanged?(false)
            },
            onError: { [weak self] _ in
                self?.onError?("Erro ao carregar entradas.")
                self?.onLoadingChanged?(false)
            }
        )
    }

    private static func map(_ entry: JournalEntry) -> EntryDisplayModel {

        let preview = entry.body
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(80)
            .replacingOccurrences(of: "\n", with: " ")

        return EntryDisplayModel(
            title: entry.title,
            bodyPreview: preview.isEmpty ? "Sem conteúdo" : String(preview),
            subtitle: AppConstants.Formatters.entryDate.string(from: entry.createdAt),
            accessory: entry.mood.emoji
        )
    }
}
