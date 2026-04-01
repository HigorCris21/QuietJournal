import Foundation

@MainActor
final class HomeViewModel: HomeViewModelProtocol {

    // MARK: - State

    var onStateChanged: ((HomeState) -> Void)?

    // MARK: - Navigation

    var onLogout: (() -> Void)?
    var onNewEntry: (() -> Void)?
    var onEditEntry: ((JournalEntry) -> Void)?

    // MARK: - Internal State

    private var entries: [JournalEntry] = []

    // MARK: - Dependencies

    private let getEntriesUseCase: GetEntriesUseCase
    private let deleteEntryUseCase: DeleteEntryUseCase
    private let authService: AuthServiceProtocol
    private let uid: String

    private var streamTask: Task<Void, Never>?

    // MARK: - Init

    init(getEntriesUseCase: GetEntriesUseCase,
         deleteEntryUseCase: DeleteEntryUseCase,
         authService: AuthServiceProtocol,
         uid: String) {

        self.getEntriesUseCase = getEntriesUseCase
        self.deleteEntryUseCase = deleteEntryUseCase
        self.authService = authService
        self.uid = uid
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        observeEntries()
    }

    deinit {
        streamTask?.cancel()
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

        let entry = entries[index]

        Task {
            onStateChanged?(.loading)

            do {
                try await deleteEntryUseCase.execute(id: entry.id, uid: uid)
            } catch {
                onStateChanged?(.error(.deleteFailed))
            }
        }
    }

    func logout() {
        do {
            try authService.logout()
            streamTask?.cancel()
            onLogout?()
        } catch {
            onStateChanged?(.error(.logoutFailed))
        }
    }

    // MARK: - Private

    private func observeEntries() {

        onStateChanged?(.loading)

        streamTask = Task { [weak self] in
            guard let self else { return }

            for await entries in getEntriesUseCase.execute(uid: uid) {

                self.entries = entries

                let display = entries.map(EntryDisplayMapper.map)

                self.onStateChanged?(.loaded(display))
            }
        }
    }
}
