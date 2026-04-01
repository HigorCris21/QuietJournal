//
//  JournalReadServiceProtocol.swift
//  QuietJournal


import Foundation

protocol JournalReadServiceProtocol {
    func entriesStream(for uid: String) -> AsyncStream<[JournalEntry]>
}
