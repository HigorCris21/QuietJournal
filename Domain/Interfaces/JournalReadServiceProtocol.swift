//
//  JournalReadServiceProtocol.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 30/03/26.
//

import Foundation

protocol JournalReadServiceProtocol {
    func observeEntries(
        for uid: String,
        onUpdate: @escaping ([JournalEntry]) -> Void,
        onError: @escaping (Error) -> Void
    )

    func stopObserving()
}
