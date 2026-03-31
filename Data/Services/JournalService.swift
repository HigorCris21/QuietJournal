// Data/Services/JournalService.swift

import Foundation
import FirebaseFirestore

final class JournalService: JournalReadServiceProtocol, JournalWriteServiceProtocol {

    // MARK: - Properties

    private let db = Firestore.firestore()

    // MARK: - Helpers

    private func entriesCollection(for uid: String) -> CollectionReference {
        db.collection("users")
          .document(uid)
          .collection("entries")
    }

    // MARK: - READ (AsyncStream)

    func entriesStream(for uid: String) -> AsyncStream<[JournalEntry]> {

        return AsyncStream { continuation in

            let listener = entriesCollection(for: uid)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in

                    if let error = error {
                        print("Firestore error:", error)
                        continuation.yield([])
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }

                    let entries: [JournalEntry] = documents.compactMap { doc in
                        JournalEntry.fromFirestore(
                            id: doc.documentID,
                            data: doc.data()
                        )
                    }

                    continuation.yield(entries)
                }

            // 🔥 Importantíssimo: cleanup correto
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }

    // MARK: - WRITE

    func createEntry(_ entry: JournalEntry) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

            entriesCollection(for: entry.uid)
                .document(entry.id)
                .setData(entry.toFirestore()) { error in

                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }

    func updateEntry(_ entry: JournalEntry) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

            entriesCollection(for: entry.uid)
                .document(entry.id)
                .updateData(entry.toFirestore()) { error in

                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }

    func deleteEntry(id: String, for uid: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

            entriesCollection(for: uid)
                .document(id)
                .delete { error in

                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }
}
