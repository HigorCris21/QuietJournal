//
//  JournalWriteServiceProtocol.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 30/03/26.
//

import Foundation

import Foundation

protocol JournalWriteServiceProtocol: AnyObject {

    func createEntry(_ entry: JournalEntry) async throws
    func updateEntry(_ entry: JournalEntry) async throws
    func deleteEntry(id: String, for uid: String) async throws
}
