import UIKit

@MainActor
final class HomeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let journalReadService: JournalReadServiceProtocol
    private let journalWriteService: JournalWriteServiceProtocol
    private let authService: AuthServiceProtocol
    private let uid: String

    var onLogout: (() -> Void)?

    init(navigationController: UINavigationController,
         journalReadService: JournalReadServiceProtocol,
         journalWriteService: JournalWriteServiceProtocol,
         authService: AuthServiceProtocol,
         uid: String) {

        self.navigationController = navigationController
        self.journalReadService = journalReadService
        self.journalWriteService = journalWriteService
        self.authService = authService
        self.uid = uid
    }

    func start() {
        showHome()
    }

    private func showHome() {

        let getEntriesUseCase = GetEntriesUseCase(service: journalReadService)
        let deleteEntryUseCase = DeleteEntryUseCase(service: journalWriteService)

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

        let createUseCase = CreateEntryUseCase(service: journalWriteService)
        let updateUseCase = UpdateEntryUseCase(service: journalWriteService)

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

        let createUseCase = CreateEntryUseCase(service: journalWriteService)
        let updateUseCase = UpdateEntryUseCase(service: journalWriteService)

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

    private func bindEntryCallbacks(_ viewModel: EntryViewModel) {
        viewModel.onSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        viewModel.onCancelled = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
    }
}
