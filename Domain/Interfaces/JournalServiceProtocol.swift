// JournalServiceProtocol.swift
// QuietJournal — Domain/Interfaces

import Foundation

// Contrato que define o que qualquer serviço de entradas do diário deve saber fazer.

protocol JournalServiceProtocol {

    // Busca todas as entradas do usuário em tempo real
    // Chama o completion sempre que houver mudança no Firestore
    func fetchEntries(for uid: String,
                      completion: @escaping (Result<[JournalEntry], Error>) -> Void)

    // Cria uma nova entrada no Firestore
    func createEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void)

    // Atualiza uma entrada existente
    func updateEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void)

    // Deleta uma entrada pelo ID
    func deleteEntry(id: String,
                     completion: @escaping (Result<Void, Error>) -> Void)
}
