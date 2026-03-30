import Foundation
import FirebaseFirestore

final class JournalService: JournalServiceProtocol {

    // MARK: - Properties

    private let db = Firestore.firestore()

    private func entriesCollection(for uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("entries")
    }

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Fetch (realtime)

    func fetchEntries(for uid: String,
                      completion: @escaping (Result<[JournalEntry], Error>) -> Void) {

        listener?.remove()

        listener = entriesCollection(for: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let entries = documents.compactMap { doc -> JournalEntry? in
                    var data = doc.data()

                    if let ts = data["createdAt"] as? Timestamp {
                        data["createdAt"] = ts.dateValue()
                    }
                    if let ts = data["updatedAt"] as? Timestamp {
                        data["updatedAt"] = ts.dateValue()
                    }

                    return JournalEntry.fromFirestore(id: doc.documentID, data: data)
                }

                completion(.success(entries))
            }
    }

    // MARK: - Stop Listening

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Async CRUD (novo)

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

    // MARK: - Legacy CRUD (mantido)

    func createEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: entry.uid)
            .document(entry.id)
            .setData(entry.toFirestore()) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func updateEntry(_ entry: JournalEntry,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: entry.uid)
            .document(entry.id)
            .updateData(entry.toFirestore()) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func deleteEntry(id: String,
                     for uid: String,
                     completion: @escaping (Result<Void, Error>) -> Void) {

        entriesCollection(for: uid)
            .document(id)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
