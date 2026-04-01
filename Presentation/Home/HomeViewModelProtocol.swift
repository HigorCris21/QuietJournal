import Foundation

protocol HomeViewModelProtocol {

    // MARK: - State

    var onStateChanged: ((HomeState) -> Void)? { get set }

    // MARK: - Navigation

    var onLogout: (() -> Void)? { get set }
    var onNewEntry: (() -> Void)? { get set }
    var onEditEntry: ((JournalEntry) -> Void)? { get set }

    // MARK: - Lifecycle

    func viewDidLoad()

    // MARK: - Actions

    func newEntryTapped()
    func selectEntry(at index: Int)
    func deleteEntry(at index: Int)
    func logout()
}
