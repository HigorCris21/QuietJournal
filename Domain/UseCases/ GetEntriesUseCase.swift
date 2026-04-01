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

    func execute(uid: String) -> AsyncStream<[JournalEntry]> {
        service.entriesStream(for: uid)
    }
}


