// Presentation/Auth/Login/LoginViewController.swift
// QuietJournal — Presentation/Auth

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: LoginViewModel

    // MARK: - UI Components

    private lazy var emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder    = AppConstants.Strings.Auth.emailPlaceholder
        tf.keyboardType   = .emailAddress
        tf.autocapitalizationType = .none
        tf.borderStyle    = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder  = AppConstants.Strings.Auth.passwordPlaceholder
        tf.isSecureTextEntry = true
        tf.borderStyle  = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(AppConstants.Strings.Auth.loginTitle, for: .normal)
        btn.backgroundColor = AppConstants.Colors.primary
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(AppConstants.Strings.Auth.registerTitle, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppConstants.Colors.background

        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),

            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16)
        ])
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating()
                      : self?.activityIndicator.stopAnimating()
            self?.loginButton.isEnabled = !isLoading
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        viewModel.login(
            email:    emailField.text ?? "",
            password: passwordField.text ?? ""
        )
    }

    @objc private func registerTapped() {
        viewModel.registerTapped()
    }
}
