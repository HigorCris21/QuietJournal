import UIKit

final class EntryViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: EntryViewModel

    // MARK: - UI

    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Título"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let bodyTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let moodSegmentedControl: UISegmentedControl = {
        let items = Mood.allCases.map { $0.emoji }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Init

    init(viewModel: EntryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupNav()
        bind()

        populate()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        [titleField, moodSegmentedControl, bodyTextView, activityIndicator]
            .forEach { view.addSubview($0) }

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            moodSegmentedControl.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            moodSegmentedControl.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            moodSegmentedControl.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),

            bodyTextView.topAnchor.constraint(equalTo: moodSegmentedControl.bottomAnchor, constant: 16),
            bodyTextView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            bodyTextView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            bodyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNav() {

        title = viewModel.isEditing ? "Editar" : "Nova entrada"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Salvar",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancelar",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    private func populate() {
        titleField.text = viewModel.initialTitle
        bodyTextView.text = viewModel.initialBody

        if let index = Mood.allCases.firstIndex(of: viewModel.initialMood) {
            moodSegmentedControl.selectedSegmentIndex = index
        }
    }

    private func bind() {

        viewModel.onLoadingChanged = { [weak self] loading in
            guard let self else { return }

            loading
                ? self.activityIndicator.startAnimating()
                : self.activityIndicator.stopAnimating()

            self.navigationItem.rightBarButtonItem?.isEnabled = !loading
        }

        viewModel.onError = { [weak self] message in
            guard let self else { return }

            let alert = UIAlertController(
                title: "Erro",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func saveTapped() {

        let index = moodSegmentedControl.selectedSegmentIndex

        let mood = Mood.allCases.indices.contains(index)
            ? Mood.allCases[index]
            : .neutral

        viewModel.save(
            title: titleField.text ?? "",
            body: bodyTextView.text ?? "",
            mood: mood
        )
    }

    @objc private func cancelTapped() {
        viewModel.cancel()
    }
}
