//
//  JournalRepository.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 07/04/26.
//
import Foundation

final class JournalRepository: JournalRepositoryProtocol {
    
    private let readService: JournalReadServiceProtocol
    private let writeService: JournalWriteServiceProtocol
    
    init(
        readService: JournalReadServiceProtocol,
        writeService: JournalWriteServiceProtocol
    ) {
        self.readService = readService
        self.writeService = writeService
    }
    
    func observeEntries(userId: String) -> AsyncStream<[JournalEntry]> {
        return readService.observeEntries(userId: userId)
    }
    
    func createEntry(_ entry: JournalEntry) async throws {
        try await writeService.createEntry(entry) // ✅ corrigido
    }
    
    func updateEntry(_ entry: JournalEntry) async throws {
        try await writeService.updateEntry(entry) // ✅ corrigido
    }
    
    func deleteEntry(entryId: String, userId: String) async throws {
        try await writeService.deleteEntry(entryId: entryId, userId: userId) // ✅ corrigido
    }
}
