// Data/Services/JournalService.swift
// QuietJournal — Data/Services

import Foundation
import FirebaseFirestore

final class JournalService: JournalServiceProtocol {

    // MARK: - Properties

    private let db = Firestore.firestore()

    private func entriesCollection(for uid: String) -> CollectionReference {
        return db.collection("users").document(uid).collection("entries")
    }

    // MARK: - Fetch

    func fetchEntries(for uid: String,
                      completion: @escaping (Result<[JournalEntry], Error>) -> Void) {

        entriesCollection(for: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        completion(.success([]))
                        return
                    }

                    let entries = documents.compactMap { doc in
                        JournalEntry.fromFirestore(id: doc.documentID, data: doc.data())
                    }

                    completion(.success(entries))
                }
            }
    }

    // MARK: - Create

    func createEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: entry.uid)
            .document(entry.id)
            .setData(entry.toFirestore()) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
    }

    // MARK: - Update

    func updateEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: entry.uid)
            .document(entry.id)
            .updateData(entry.toFirestore()) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
    }

    // MARK: - Delete

    func deleteEntry(id: String,
                     for uid: String,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: uid)
            .document(id)
            .delete { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
            }
    }
}
