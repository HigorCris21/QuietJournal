//
//  JournalReadServiceProtocol.swift
//  QuietJournal


import Foundation

protocol JournalReadServiceProtocol {
    func observeEntries(userId: String) -> AsyncStream<[JournalEntry]>
}
