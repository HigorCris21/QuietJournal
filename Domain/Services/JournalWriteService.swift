import Foundation
import FirebaseFirestore

final class JournalWriteService: JournalWriteServiceProtocol {

    private let db = Firestore.firestore()

    private func entriesCollection(for uid: String) -> CollectionReference {
        db.collection("users")
            .document(uid)
            .collection("entries")
    }

    func createEntry(_ entry: JournalEntry) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

            entriesCollection(for: entry.uid)
                .document(entry.id)
                .setData(JournalEntryMapper.toFirestore(entry)) { error in

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
                .updateData(JournalEntryMapper.toFirestore(entry)) { error in

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



