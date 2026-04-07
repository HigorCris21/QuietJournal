//
//  Untitled.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 01/04/26.
//

import Foundation

final class GetEntriesUseCase {

    private let service: JournalReadServiceProtocol

    init(service: JournalReadServiceProtocol) {
        self.service = service
    }

    func execute(userId: String) -> AsyncStream<[JournalEntry]> {
        return service.observeEntries(userId: userId) 
    }
}




