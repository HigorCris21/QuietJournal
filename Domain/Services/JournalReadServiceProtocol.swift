//
//  JournalReadServiceProtocol.swift
//  QuietJournal


import Foundation

protocol JournalReadServiceProtocol {

    /// Stream reativo de entries em tempo real
    func entriesStream(for uid: String) -> AsyncStream<[JournalEntry]>
}
