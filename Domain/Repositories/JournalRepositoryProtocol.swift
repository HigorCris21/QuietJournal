//
//  JournalRepositoryProtocol.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 07/04/26.
//

import Foundation

protocol JournalRepositoryProtocol {
    
    func observeEntries(userId: String) -> AsyncStream<[JournalEntry]>
    
    func createEntry(_ entry: JournalEntry) async throws
    
    func updateEntry(_ entry: JournalEntry) async throws
    
    func deleteEntry(entryId: String, userId: String) async throws
}



