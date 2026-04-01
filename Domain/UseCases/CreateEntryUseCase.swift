//
//  CreateEntryUseCase.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 01/04/26.
//

import Foundation

final class CreateEntryUseCase {

    private let service: JournalWriteServiceProtocol

    init(service: JournalWriteServiceProtocol) {
        self.service = service
    }

    func execute(_ entry: JournalEntry) async throws {
        try await service.createEntry(entry)
    }
}
