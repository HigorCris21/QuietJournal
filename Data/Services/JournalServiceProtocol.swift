// JournalServiceProtocol.swift

import Foundation

protocol JournalServiceProtocol {

    // MARK: - Realtime (mantido)

    func fetchEntries(for uid: String,
                      completion: @escaping (Result<[JournalEntry], Error>) -> Void)

    // MARK: - Async (novo - nível pleno)

    func createEntry(_ entry: JournalEntry) async throws
    func updateEntry(_ entry: JournalEntry) async throws
    func deleteEntry(id: String, for uid: String) async throws

    // MARK: - Legacy (opcional manter por compatibilidade)

    func createEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void)

    func updateEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void)

    func deleteEntry(id: String,
                     for uid: String,
                     completion: @escaping (Result<Void, Error>) -> Void)

    func stopListening()
}
