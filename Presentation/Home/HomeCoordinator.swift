// Presentation/Home/HomeCoordinator.swift

import UIKit

@MainActor
final class HomeCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let journalReadService: JournalReadServiceProtocol
    private let journalWriteService: JournalWriteServiceProtocol
    private let authService: AuthServiceProtocol
    private let uid: String

    var onLogout: (() -> Void)?

    // MARK: - Init

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

    // MARK: - Start

    func start() {
        showHome()
    }

    // MARK: - Flows

    private func showHome() {

        let viewModel = HomeViewModel(
            readService: journalReadService,
            writeService: journalWriteService,
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

    // ✅ CORREÇÃO AQUI
    private func showNewEntry() {

        let viewModel = EntryViewModel(
            journalService: journalWriteService,
            uid: uid,
            entry: nil // 🔥 nova entry = nil
        )

        viewModel.onSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        viewModel.onCancelled = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showEditEntry(_ entry: JournalEntry) {

        let viewModel = EntryViewModel(
            journalService: journalWriteService,
            uid: uid,
            entry: entry // 🔥 edição = objeto real
        )

        viewModel.onSaved = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        viewModel.onCancelled = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        let vc = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
