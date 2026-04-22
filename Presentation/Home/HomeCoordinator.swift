import UIKit

@MainActor
final class HomeCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let authService: AuthServiceProtocol
    private let uid: String

    // Services
    private let journalReadService: JournalReadServiceProtocol
    private let journalWriteService: JournalWriteServiceProtocol

    // Repository
    private lazy var journalRepository: JournalRepositoryProtocol = {
        JournalRepository(
            readService: journalReadService,
            writeService: journalWriteService
        )
    }()

    var onLogout: (() -> Void)?

    // MARK: - Init

    init(
        navigationController: UINavigationController,
        journalReadService: JournalReadServiceProtocol,
        journalWriteService: JournalWriteServiceProtocol,
        authService: AuthServiceProtocol,
        uid: String
    ) {
        self.navigationController = navigationController
        self.journalReadService = journalReadService
        self.journalWriteService = journalWriteService
        self.authService = authService
        self.uid = uid
    }

    // MARK: - Start

    func start() {
        showHome()
    }

    // MARK: - Home

    private func showHome() {

        // ✅ TODOS os UseCases agora usam repository
        let getEntriesUseCase = GetEntriesUseCase(repository: journalRepository)
        let deleteEntryUseCase = DeleteEntryUseCase(repository: journalRepository)

        let viewModel = HomeViewModel(
            getEntriesUseCase: getEntriesUseCase,
            deleteEntryUseCase: deleteEntryUseCase,
            authService: authService,
            uid: uid
        )

        viewModel.onLogout = { [weak self] in
            self?.onLogout?()
        }

        viewModel.onNewEntry = { [weak self] in
            self?.showNewEntry()
        }

        viewModel.onEditEntry = { [weak self] entry in
            self?.showEditEntry(entry)
        }

        let vc = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: true)
    }

    // MARK: - Entry Flow

    private func showNewEntry() {

        let createUseCase = CreateEntryUseCase(repository: journalRepository)
        let updateUseCase = UpdateEntryUseCase(repository: journalRepository)

        let viewModel = EntryViewModel(
            createEntryUseCase: createUseCase,
            updateEntryUseCase: updateUseCase,
            uid: uid,
            entry: nil
        )

        bindEntryCallbacks(viewModel)

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showEditEntry(_ entry: JournalEntry) {

        let createUseCase = CreateEntryUseCase(repository: journalRepository)
        let updateUseCase = UpdateEntryUseCase(repository: journalRepository)

        let viewModel = EntryViewModel(
            createEntryUseCase: createUseCase,
            updateEntryUseCase: updateUseCase,
            uid: uid,
            entry: entry
        )

        bindEntryCallbacks(viewModel)

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Bindings

    private func bindEntryCallbacks(_ viewModel: EntryViewModel) {
        viewModel.onSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        viewModel.onCancelled = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
    }
}
