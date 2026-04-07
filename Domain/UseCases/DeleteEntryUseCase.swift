//
//  DeleteEntryUseCase.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 01/04/26.
//

import Foundation

final class DeleteEntryUseCase {

    private let service: JournalWriteServiceProtocol

    init(service: JournalWriteServiceProtocol) {
        self.service = service
    }

    func execute(entryId: String, userId: String) async throws {
        try await service.deleteEntry(entryId: entryId, userId: userId)
    }
}
