import Foundation

@MainActor
final class HomeViewModel {

    private let getEntriesUseCase: GetEntriesUseCase
    private let deleteEntryUseCase: DeleteEntryUseCase
    private let authService: AuthServiceProtocol
    private let uid: String

    private(set) var state: HomeState = .idle {
        didSet { onStateChanged?(state) }
    }

    private var streamTask: Task<Void, Never>?
    private var currentEntries: [JournalEntry] = []

    var onStateChanged: ((HomeState) -> Void)?
    var onLogout: (() -> Void)?
    var onNewEntry: (() -> Void)?
    var onEditEntry: ((JournalEntry) -> Void)?

    init(
        getEntriesUseCase: GetEntriesUseCase,
        deleteEntryUseCase: DeleteEntryUseCase,
        authService: AuthServiceProtocol,
        uid: String
    ) {
        self.getEntriesUseCase = getEntriesUseCase
        self.deleteEntryUseCase = deleteEntryUseCase
        self.authService = authService
        self.uid = uid
    }

    func start() {
        observeEntries()
    }

    private func observeEntries() {

        state = .loading
        streamTask?.cancel()

        streamTask = Task { [weak self] in
            guard let self = self else { return }

            let stream = self.getEntriesUseCase.execute(userId: self.uid)

            for await entries in stream {

                if Task.isCancelled { return }

                self.currentEntries = entries

                self.state = entries.isEmpty
                    ? .empty
                    : .loaded(entries)
            }
        }
    }

    // MARK: - Actions

    func delete(entry: JournalEntry) {
        Task {
            do {
                try await deleteEntryUseCase.execute(
                    entryId: entry.id,
                    userId: uid
                )
            } catch {
                state = .error(.deleteFailed)
            }
        }
    }

    func deleteEntryById(_ id: String) {
        guard let entry = currentEntries.first(where: { $0.id == id }) else { return }
        delete(entry: entry)
    }

    func selectEntry(_ entry: JournalEntry) {
        onEditEntry?(entry)
    }

    func selectEntryById(_ id: String) {
        guard let entry = currentEntries.first(where: { $0.id == id }) else { return }
        onEditEntry?(entry)
    }

    func logout() {
        do {
            try authService.logout()
            onLogout?()
        } catch {
            state = .error(.logoutFailed)
        }
    }

    func newEntry() {
        onNewEntry?()
    }

    deinit {
        streamTask?.cancel()
    }
}
