// Presentation/Home/HomeViewController.swift
// QuietJournal — Presentation/Home

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: HomeViewModel

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = UITableView.automaticDimension
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text          = "Nenhuma entrada ainda.\nToque em + para começar."
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor     = AppConstants.Colors.text
        lbl.isHidden      = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppConstants.Colors.background
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.dataSource = self
        tableView.delegate   = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        title = "QuietJournal"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(newEntryTapped)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Sair",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }

    private func bindViewModel() {
        viewModel.onEntriesUpdated = { [weak self] entries in
            self?.emptyLabel.isHidden = !entries.isEmpty
            self?.tableView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func newEntryTapped() {
        viewModel.newEntryTapped()
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Sair",
            message: "Deseja encerrar a sessão?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sair", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "EntryCell")
        let entry = viewModel.entries[indexPath.row]

        cell.textLabel?.text       = "\(entry.mood.emoji)  \(entry.title)"
        cell.detailTextLabel?.text = entry.body
        cell.accessoryType         = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.editEntry(viewModel.entries[indexPath.row])
    }

    // ✅ ITEM 3 — Confirmação antes de deletar
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }

        // Captura a entry ANTES de mostrar o alerta.
        // Se o listener do Firestore atualizar a lista enquanto o alerta
        // está aberto, o indexPath pode ficar desatualizado. Guardar a
        // entry por referência garante que deletamos a coisa certa.
        let entry = viewModel.entries[indexPath.row]

        let alert = UIAlertController(
            title: "Deletar entrada",
            message: "Essa ação não pode ser desfeita. Deseja continuar?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        alert.addAction(UIAlertAction(title: "Deletar", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteEntry(entry)
        })

        present(alert, animated: true)
    }
}
