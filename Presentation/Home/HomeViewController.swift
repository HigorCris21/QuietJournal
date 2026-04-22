import UIKit

final class HomeViewController: UIViewController {

    private enum Section {
        case main
    }

    private let viewModel: HomeViewModel

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

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
            activityIndicator.startAnimating()

        case .loaded(let entries):
            activityIndicator.stopAnimating()
            apply(entries)

        case .empty:
            activityIndicator.stopAnimating()
            apply([])

        case .error:
            activityIndicator.stopAnimating()
            apply([])

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
}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.selectEntryById(model.id)
    }
}
