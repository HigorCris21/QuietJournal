import UIKit

final class HomeViewController: UIViewController {

    private enum Section {
        case main
    }

    private let viewModel: HomeViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Nenhuma entrada ainda.\nToque em + para criar a primeira."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private var dataSource: UITableViewDiffableDataSource<Section, EntryDisplayModel>!

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTable()
        setupAuxiliaryViews()
        setupNavigation()
        setupDataSource()
        bind()

        viewModel.start()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.reuseIdentifier)
        tableView.delegate = self
    }

    private func setupAuxiliaryViews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupNavigation() {
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

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, EntryDisplayModel>(
            tableView: tableView
        ) { tableView, indexPath, model in

            let cell = tableView.dequeueReusableCell(
                withIdentifier: EntryCell.reuseIdentifier,
                for: indexPath
            ) as! EntryCell

            cell.configure(with: model)
            return cell
        }
    }

    private func bind() {
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: HomeState) {

        switch state {

        case .loading:
            emptyLabel.isHidden = true
            activityIndicator.startAnimating()

        case .loaded(let entries):
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = true
            apply(entries)

        case .empty:
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = false
            apply([])

        case .error(let error):
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = false
            apply([])
            showError(error.message)

        case .idle:
            break
        }
    }

    private func apply(_ entries: [JournalEntry]) {

        let models = entries.map { EntryDisplayMapper.map($0) }

        var snapshot = NSDiffableDataSourceSnapshot<Section, EntryDisplayModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(models)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func showDeleteConfirmation(for id: String) {
        let alert = UIAlertController(
            title: "Excluir entrada",
            message: AppConstants.Strings.Journal.deleteConfirm,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Excluir", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteEntryById(id)
        })

        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func newEntryTapped() {
        viewModel.newEntry()
    }

    @objc private func logoutTapped() {
        viewModel.logout()
    }
}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.selectEntryById(model.id)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Excluir") { [weak self] _, _, completion in
            self?.showDeleteConfirmation(for: model.id)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
