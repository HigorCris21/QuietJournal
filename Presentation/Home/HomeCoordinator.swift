import UIKit

@MainActor
final class HomeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    private let uid: String

    var onLogout: (() -> Void)?

    init(
        navigationController: UINavigationController,
        diContainer: AppDIContainer,
        uid: String
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.uid = uid
    }

    func start() {
        showHome()
    }

    private func showHome() {

        let viewModel = HomeViewModel(
            getEntriesUseCase: diContainer.makeGetEntriesUseCase(),
            deleteEntryUseCase: diContainer.makeDeleteEntryUseCase(),
            authService: diContainer.makeAuthService(),
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

        let viewModel = EntryViewModel(
            createEntryUseCase: diContainer.makeCreateEntryUseCase(),
            updateEntryUseCase: diContainer.makeUpdateEntryUseCase(),
            uid: uid,
            entry: nil
        )

        bind(viewModel)

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showEditEntry(_ entry: JournalEntry) {

        let viewModel = EntryViewModel(
            createEntryUseCase: diContainer.makeCreateEntryUseCase(),
            updateEntryUseCase: diContainer.makeUpdateEntryUseCase(),
            uid: uid,
            entry: entry
        )

        bind(viewModel)

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func bind(_ viewModel: EntryViewModel) {

        viewModel.onSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        viewModel.onCancelled = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
    }
}
