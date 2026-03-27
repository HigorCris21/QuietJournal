// Presentation/Home/HomeViewModelProtocol.swift
// QuietJournal — Presentation/Home

import Foundation

protocol HomeViewModelProtocol: AnyObject {

    // Callbacks
    var onEntriesUpdated: (([JournalEntry]) -> Void)? { get set }
    var onError:          ((String) -> Void)?          { get set }
    var onLogout:         (() -> Void)?                { get set }
    var onNewEntry:       (() -> Void)?                { get set }
    var onEditEntry:      ((JournalEntry) -> Void)?    { get set }
    var onLoadingChanged: ((Bool) -> Void)?            { get set }

    // State
    var entries: [JournalEntry] { get }

    // Actions
    func viewDidLoad()
    func newEntryTapped()
    func editEntry(_ entry: JournalEntry)
    func deleteEntry(_ entry: JournalEntry)
    func logout()
}
