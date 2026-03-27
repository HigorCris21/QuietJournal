// Presentation/Home/HomeViewController.swift
// QuietJournal — Presentation/Home

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    // Depende do protocolo, não da classe concreta
    private let viewModel: HomeViewModelProtocol

    private let entryCellID = AppConstants.Strings.Cell.entryCell

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight          = UITableView.automaticDimension
        // ✅ estimatedRowHeight melhora a performance do scroll
        // sem ele o iOS calcula todas as alturas antes de renderizar
        tv.estimatedRowHeight = 60
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

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init

    // Recebe o protocolo — qualquer conformante funciona aqui
    init(viewModel: HomeViewModelProtocol) {
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
        view.addSubview(activityIndicator)

        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: entryCellID)
        tableView.tableFooterView = UIView()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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

        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
                self?.tableView.isHidden  = true
                self?.emptyLabel.isHidden = true
            } else {
                self?.activityIndicator.stopAnimating()
                self?.tableView.isHidden = false
            }
        }

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
// Conformidade isolada em extension — responsabilidade única de fornecer dados

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.entries.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: entryCellID, for: indexPath)

        //Acesso seguro ao array — evita crash se entries mudar
        guard indexPath.row < viewModel.entries.count else { return cell }

        let entry = viewModel.entries[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text          = "\(entry.mood.emoji)  \(entry.title)"
        content.secondaryText = entry.body

        cell.contentConfiguration = content
        cell.accessoryType        = .disclosureIndicator

        return cell
    }
}

// MARK: - UITableViewDelegate
// Conformidade isolada em extension — responsabilidade única de responder interações

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)


        guard indexPath.row < viewModel.entries.count else { return }
        viewModel.editEntry(viewModel.entries[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }

        guard indexPath.row < viewModel.entries.count else { return }
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
