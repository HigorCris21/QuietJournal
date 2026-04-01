import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private var viewModel: HomeViewModelProtocol

    private var entries: [EntryDisplayModel] = []

    // MARK: - UI

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Init

    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()

        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        title = "Journal"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self

        tableView.frame = view.bounds
        view.addSubview(tableView)

        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }

    private func bindViewModel() {

        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }

            switch state {

            case .idle:
                break

            case .loading:
                self.showLoading()

            case .loaded(let entries):
                self.hideLoading()
                self.entries = entries
                self.tableView.reloadData()

            case .error(let error):
                self.hideLoading()
                self.showError(error)
            }
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        viewModel.newEntryTapped()
    }

    @objc private func logoutTapped() {
        viewModel.logout()
    }

    private func showLoading() {
        activityIndicator.startAnimating()
    }

    private func hideLoading() {
        activityIndicator.stopAnimating()
    }

    private func showError(_ error: HomeError) {
        let alert = UIAlertController(
            title: "Erro",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let entry = entries[indexPath.row]

        cell.textLabel?.text = entry.title
        cell.detailTextLabel?.text = entry.subtitle
        cell.accessoryView = UILabel()

        if let label = cell.accessoryView as? UILabel {
            label.text = entry.accessory
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        viewModel.selectEntry(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            viewModel.deleteEntry(at: indexPath.row)
        }
    }
}
