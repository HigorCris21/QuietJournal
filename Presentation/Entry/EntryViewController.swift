// Presentation/Entry/EntryViewController.swift
// QuietJournal — Presentation/Entry

import UIKit

final class EntryViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: EntryViewModel

    // MARK: - UI Components

    private lazy var titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Título"
        tf.borderStyle = .roundedRect
        tf.font        = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var bodyTextView: UITextView = {
        let tv = UITextView()
        tv.font               = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor  = UIColor.systemGray4.cgColor
        tv.layer.borderWidth  = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var moodSegmentedControl: UISegmentedControl = {
        let items = Mood.allCases.map { "\($0.emoji) \($0.label)" }
        let sc    = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private lazy var moodLabel: UILabel = {
        let lbl = UILabel()
        lbl.text      = "Como você está?"
        lbl.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = AppConstants.Colors.text
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init

    init(viewModel: EntryViewModel) {
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
        populateFields()
        setupKeyboardObservers()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppConstants.Colors.background

        // D: depende do protocolo UITextViewDelegate, não de classe concreta
        bodyTextView.delegate = self

        view.addSubview(titleField)
        view.addSubview(moodLabel)
        view.addSubview(moodSegmentedControl)
        view.addSubview(bodyTextView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            moodLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            moodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            moodSegmentedControl.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 8),
            moodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            moodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            bodyTextView.topAnchor.constraint(equalTo: moodSegmentedControl.bottomAnchor, constant: 20),
            bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bodyTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        title = viewModel.isEditing
            ? AppConstants.Strings.Journal.editEntryTitle
            : AppConstants.Strings.Journal.newEntryTitle

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

    private func populateFields() {
        titleField.text = viewModel.initialTitle

        if viewModel.initialBody.isEmpty {
            // Responsabilidade delegada à extensão — ViewController não sabe "como"
            bodyTextView.showPlaceholder(AppConstants.Strings.Journal.bodyPlaceholder)
        } else {
            bodyTextView.text      = viewModel.initialBody
            bodyTextView.textColor = AppConstants.Colors.text
        }

        if let index = Mood.allCases.firstIndex(of: viewModel.initialMood) {
            moodSegmentedControl.selectedSegmentIndex = index
        }
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating()
                      : self?.activityIndicator.stopAnimating()
            self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Keyboard

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        bodyTextView.contentInset          = inset
        bodyTextView.scrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide() {
        bodyTextView.contentInset          = .zero
        bodyTextView.scrollIndicatorInsets = .zero
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        let index        = moodSegmentedControl.selectedSegmentIndex
        let selectedMood = Mood.allCases.indices.contains(index)
            ? Mood.allCases[index]
            : .neutral

        // isShowingPlaceholder vive na extensão — não na ViewController
        let bodyText = bodyTextView.isShowingPlaceholder ? "" : bodyTextView.text

        viewModel.save(
            title: titleField.text ?? "",
            body:  bodyText ?? "",
            mood:  selectedMood
        )
    }

    @objc private func cancelTapped() {
        viewModel.cancel()
    }
}

// MARK: - UITextViewDelegate

extension EntryViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.isShowingPlaceholder {
            textView.hidePlaceholder(textColor: AppConstants.Colors.text)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.showPlaceholder(AppConstants.Strings.Journal.bodyPlaceholder)
        }
    }
}
