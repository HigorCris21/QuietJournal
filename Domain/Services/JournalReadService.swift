import Foundation
import FirebaseFirestore

final class JournalReadService: JournalReadServiceProtocol {

    private let db = Firestore.firestore()

    private func entriesCollection(for userId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("entries")
    }

    func observeEntries(userId: String) -> AsyncStream<[JournalEntry]> {
        
        AsyncStream { continuation in

            let listener = entriesCollection(for: userId)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in

                    if let error = error {
                        print("🔥 Firestore error:", error)
                        continuation.finish() // ✅ corrigido
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }

                    let entries: [JournalEntry] = documents.compactMap { doc in
                        JournalEntryMapper.fromFirestore(
                            id: doc.documentID,
                            data: doc.data()
                        )
                    }

                    continuation.yield(entries)
                }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}
