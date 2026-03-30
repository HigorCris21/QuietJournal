// Presentation/Home/EntryCell.swift
// QuietJournal — Presentation/Home

import UIKit

final class EntryCell: UITableViewCell {

    // MARK: - Reutilização
    static let reuseIdentifier = "EntryCell"

    // MARK: - Layout Constants
    private enum Layout {
        static let leadingPadding: CGFloat = 12
        static let trailingPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 10
        static let stackSpacing: CGFloat = 3
        static let moodSize: CGFloat = 44
    }

    // MARK: - UI Components

    private let moodLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 32)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let previewLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .tertiaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var textStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, previewLabel, dateLabel])
        sv.axis = .vertical
        sv.spacing = Layout.stackSpacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    // MARK: - Setup

    private func setupUI() {
        accessoryType = .disclosureIndicator
        selectionStyle = .default
        backgroundColor = .systemBackground

        contentView.addSubview(moodLabel)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            moodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.leadingPadding),
            moodLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moodLabel.widthAnchor.constraint(equalToConstant: Layout.moodSize),

            textStack.leadingAnchor.constraint(equalTo: moodLabel.trailingAnchor, constant: Layout.spacing),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.trailingPadding),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.verticalPadding),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.verticalPadding)
        ])
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        moodLabel.text = nil
        titleLabel.text = nil
        previewLabel.text = nil
        dateLabel.text = nil
    }

    // MARK: - Configure

    func configure(with model: EntryDisplayModel) {
        moodLabel.text = model.accessory.isEmpty ? "🙂" : model.accessory
        titleLabel.text = model.title
        previewLabel.text = model.bodyPreview
        dateLabel.text = model.subtitle

        configureAccessibility()
    }

    // MARK: - Accessibility

    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = [
            titleLabel.text,
            previewLabel.text,
            dateLabel.text
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
