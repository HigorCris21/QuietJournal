
import Foundation

@MainActor
final class HomeViewModel: HomeViewModelProtocol {

    // MARK: - Callbacks

    var onEntriesUpdated: (([EntryDisplayModel]) -> Void)?
    var onError: ((HomeError) -> Void)?
    var onLogout: (() -> Void)?
    var onNewEntry: (() -> Void)?
    var onEditEntry: ((JournalEntry) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - State

    private var entries: [JournalEntry] = []
    private(set) var displayEntries: [EntryDisplayModel] = []

    // MARK: - Dependencies

    private let readService: JournalReadServiceProtocol
    private let writeService: JournalWriteServiceProtocol
    private let authService: AuthServiceProtocol
    private let uid: String

    private var streamTask: Task<Void, Never>?

    // MARK: - Init

    init(readService: JournalReadServiceProtocol,
         writeService: JournalWriteServiceProtocol,
         authService: AuthServiceProtocol,
         uid: String) {

        self.readService = readService
        self.writeService = writeService
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
            onLoadingChanged?(true)

            do {
                try await writeService.deleteEntry(id: entry.id, for: uid)
            } catch {
                onError?(.deleteFailed)
            }

            onLoadingChanged?(false)
        }
    }

    func logout() {
        do {
            try authService.logout()
            streamTask?.cancel()
            onLogout?()
        } catch {
            onError?(.logoutFailed)
        }
    }

    // MARK: - Private

    private func observeEntries() {

        onLoadingChanged?(true)

        streamTask = Task { [weak self] in
            guard let self else { return }

            for await entries in readService.entriesStream(for: uid) {

                self.entries = entries

                // ✅ USANDO MAPPER (CORRETO)
                self.displayEntries = entries.map(EntryDisplayMapper.map)

                self.onEntriesUpdated?(self.displayEntries)
                self.onLoadingChanged?(false)
            }
        }
    }
}
