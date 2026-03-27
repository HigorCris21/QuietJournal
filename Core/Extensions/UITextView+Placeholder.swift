// Core/Extensions/UITextView+Placeholder.swift
// QuietJournal — Core/Extensions

import UIKit

extension UITextView {

    var isShowingPlaceholder: Bool {
        return textColor == .placeholderText
    }

    func showPlaceholder(_ text: String) {
        self.text      = text
        self.textColor = .placeholderText
    }

    func hidePlaceholder(textColor: UIColor) {
        self.text      = ""
        self.textColor = textColor
    }
}
