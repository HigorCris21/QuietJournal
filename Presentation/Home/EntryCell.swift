// Presentation/Home/EntryCell.swift
// QuietJournal — Presentation/Home

import UIKit

final class EntryCell: UITableViewCell {

    // MARK: - Reutilização

    // Centralizado: uma string, um lugar. Mesma filosofia do AppConstants.Strings.Cell.entryCell
    static let reuseIdentifier = "EntryCell"

    // MARK: - UI Components

    // Emoji do humor — âncora visual à esquerda
    private let moodLabel: UILabel = {
        let lbl = UILabel()
        lbl.font      = UIFont.systemFont(ofSize: 32)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Título da entrada — hierarquia primária
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Preview do body — contexto antes de abrir
    private let previewLabel: UILabel = {
        let lbl = UILabel()
        lbl.font          = UIFont.systemFont(ofSize: 14)
        lbl.textColor     = .secondaryLabel   // cinza semântico — respeita dark mode
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Data formatada — informação terciária, menor
    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font      = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .tertiaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Espaçamento — sem constraints manuais entre eles
    private lazy var textStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, previewLabel, dateLabel])
        sv.axis      = .vertical
        sv.spacing   = 3
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    // MARK: - Setup

    private func setupUI() {
        accessoryType = .disclosureIndicator

        contentView.addSubview(moodLabel)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([

            // Emoji: quadrado fixo à esquerda, centralizado verticalmente
            moodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            moodLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moodLabel.widthAnchor.constraint(equalToConstant: 44),

            // Stack: ocupa o espaço restante com margens confortáveis
            textStack.leadingAnchor.constraint(equalTo: moodLabel.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure
    func configure(with model: EntryDisplayModel) {
        moodLabel.text    = model.accessory
        titleLabel.text   = model.title
        previewLabel.text = model.bodyPreview
        dateLabel.text    = model.subtitle
    }
}
