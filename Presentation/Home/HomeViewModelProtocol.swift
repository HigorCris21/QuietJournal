import Foundation

protocol HomeViewModelProtocol: AnyObject {

    // MARK: - Callbacks

    var onEntriesUpdated: (([EntryDisplayModel]) -> Void)? { get set }
    var onError:          ((HomeError) -> Void)?           { get set }
    var onLogout:         (() -> Void)?                    { get set }
    var onNewEntry:       (() -> Void)?                    { get set }
    var onEditEntry:      ((JournalEntry) -> Void)?        { get set }
    var onLoadingChanged: ((Bool) -> Void)?                { get set }

    // MARK: - State

    var displayEntries: [EntryDisplayModel] { get }

    // MARK: - Actions

    func viewDidLoad()
    func newEntryTapped()
    func selectEntry(at index: Int)
    func deleteEntry(at index: Int)
    func logout()
}
