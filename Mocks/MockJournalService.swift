// QuietJournalTests/Mocks/MockJournalService.swift

@testable import QuietJournal

final class MockJournalService: JournalServiceProtocol {

    // MARK: - Estado controlável

    var fetchResult:  Result<[JournalEntry], Error> = .success([])
    var saveResult:   Result<Void, Error>           = .success(())
    var deleteResult: Result<Void, Error>           = .success(())

    // MARK: - Rastreamento de chamadas

    var fetchCalled        = false
    var createCalled       = false
    var updateCalled       = false
    var deleteCalled       = false
    var stopListeningCalled = false

    var lastCreatedEntry: JournalEntry?
    var lastUpdatedEntry: JournalEntry?
    var lastDeletedID:    String?

    // MARK: - JournalServiceProtocol

    func fetchEntries(for uid: String,
                      completion: @escaping (Result<[JournalEntry], Error>) -> Void) {
        fetchCalled = true
        completion(fetchResult)
    }

    func createEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        createCalled      = true
        lastCreatedEntry  = entry
        completion(saveResult)
    }

    func updateEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        updateCalled      = true
        lastUpdatedEntry  = entry
        completion(saveResult)
    }

    func deleteEntry(id: String,
                     for uid: String,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        deleteCalled   = true
        lastDeletedID  = id
        completion(deleteResult)
    }

    func stopListening() {
        stopListeningCalled = true
    }
}
