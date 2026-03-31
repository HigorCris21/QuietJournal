import Foundation
import FirebaseFirestore

final class JournalService: JournalReadServiceProtocol, JournalWriteServiceProtocol {

    // MARK: - Properties

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Helpers

    private func entriesCollection(for uid: String) -> CollectionReference {
        db.collection("users")
          .document(uid)
          .collection("entries")
    }

    // MARK: - READ

    func observeEntries(
        for uid: String,
        onUpdate: @escaping ([JournalEntry]) -> Void,
        onError: @escaping (Error) -> Void
    ) {

        listener?.remove()

        listener = entriesCollection(for: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    onError(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    onUpdate([])
                    return
                }

                let entries: [JournalEntry] = documents.compactMap { doc in
                    var data = doc.data()

                    if let ts = data["createdAt"] as? Timestamp {
                        data["createdAt"] = ts.dateValue()
                    }

                    if let ts = data["updatedAt"] as? Timestamp {
                        data["updatedAt"] = ts.dateValue()
                    }

                    return JournalEntry.fromFirestore(
                        id: doc.documentID,
                        data: data
                    )
                }

                onUpdate(entries)
            }
    }

    func stopObserving() {
        listener?.remove()
        listener = nil
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
