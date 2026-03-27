// Presentation/Home/HomeViewModelProtocol.swift
// QuietJournal — Presentation/Home

import Foundation

protocol HomeViewModelProtocol: AnyObject {

    // MARK: - Callbacks

    var onEntriesUpdated: (([EntryDisplayModel]) -> Void)? { get set }
    var onError:          ((String) -> Void)?              { get set }
    var onLogout:         (() -> Void)?                    { get set }
    var onNewEntry:       (() -> Void)?                    { get set }
    var onEditEntry:      ((JournalEntry) -> Void)?        { get set }
    var onLoadingChanged: ((Bool) -> Void)?                { get set }

    // MARK: - State

    //ViewController acessa apenas o modelo de display — não o de domínio
    var displayEntries: [EntryDisplayModel] { get }

    // MARK: - Actions

    func viewDidLoad()
    func newEntryTapped()

    // Ações por índice — ViewController não precisa conhecer JournalEntry
    func selectEntry(at index: Int)
    func deleteEntry(at index: Int)
    func logout()
}
