// Presentation/Home/HomeCoordinator.swift
// QuietJournal — Presentation/Home

import UIKit

@MainActor
final class HomeCoordinator: Coordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let journalService: JournalServiceProtocol
    private let authService: AuthServiceProtocol
    private let uid: String

    // Callback para avisar o AppCoordinator que o logout foi executado
    var onLogout: (() -> Void)?

    // MARK: - Init

    init(navigationController: UINavigationController,
         journalService: JournalServiceProtocol,
         authService: AuthServiceProtocol,
         uid: String) {

        self.navigationController = navigationController
        self.journalService       = journalService
        self.authService          = authService
        self.uid                  = uid
    }

    // MARK: - Start

    func start() {
        showHome()
    }

    // MARK: - Flows

    private func showHome() {

        let viewModel = HomeViewModel(
            journalService: journalService,
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

    private func showNewEntry() {

        let viewModel = EntryViewModel(
            journalService: journalService,
            uid: uid,
            entry: nil
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
            journalService: journalService,
            uid: uid,
            entry: entry
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
