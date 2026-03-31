//
//  JournalReadServiceProtocol.swift
//  QuietJournal


import Foundation

protocol JournalReadServiceProtocol: AnyObject {

    func observeEntries(
        for uid: String,
        onUpdate: @escaping ([JournalEntry]) -> Void,
        onError: @escaping (Error) -> Void
    )

    func stopObserving()
}
