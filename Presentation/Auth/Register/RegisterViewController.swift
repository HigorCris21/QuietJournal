// Presentation/Auth/Register/RegisterViewController.swift
// QuietJournal — Presentation/Auth

import UIKit

final class RegisterViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: RegisterViewModel

    // MARK: - UI Components

    private lazy var emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = AppConstants.Strings.Auth.emailPlaceholder
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = AppConstants.Strings.Auth.passwordPlaceholder
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirmar senha"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(AppConstants.Strings.Auth.registerTitle, for: .normal)
        btn.backgroundColor = AppConstants.Colors.primary
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Já tenho conta", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init

    init(viewModel: RegisterViewModel) {
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
        view.addSubview(confirmPasswordField)
        view.addSubview(registerButton)
        view.addSubview(backButton)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            confirmPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordField.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 24),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 48),

            backButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16)
        ])
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating()
                      : self?.activityIndicator.stopAnimating()
            self?.registerButton.isEnabled = !isLoading
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    // MARK: - Actions

    @objc private func registerTapped() {
        viewModel.register(
            email:           emailField.text ?? "",
            password:        passwordField.text ?? "",
            confirmPassword: confirmPasswordField.text ?? ""
        )
    }

    @objc private func backTapped() {
        viewModel.backTapped()
    }
}
```

---

## Diferenças em relação ao Login

O Register tem três validações **antes** de chamar o Firebase — isso evita chamadas de rede desnecessárias e dá feedback instantâneo ao usuário:
```
1. Campos vazios     → erro local, sem Firebase
2. Senhas diferentes → erro local, sem Firebase
3. Senha curta       → erro local, sem Firebase
4. Tudo ok           → chama Firebase
```

---

## Commit no GitHub Desktop

**Summary:**
```
Add Register flow - RegisterViewController and RegisterViewModel
```
**Description:**
```
- Add RegisterViewModel with local validations before Firebase call
- Add RegisterViewController with ViewCode layout
- Complete Auth flow: Login → Register → AppCoordinator
