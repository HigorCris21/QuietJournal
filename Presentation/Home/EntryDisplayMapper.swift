import Foundation

struct EntryDisplayMapper {

    static func map(_ entry: JournalEntry) -> EntryDisplayModel {

        let preview = entry.body
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(80)
            .replacingOccurrences(of: "\n", with: " ")

        return EntryDisplayModel(
            id: entry.id,
            title: entry.title,
            bodyPreview: preview.isEmpty ? "Sem conteúdo" : String(preview),
            subtitle: AppConstants.Formatters.entryDate.string(from: entry.createdAt),
            accessory: entry.mood.emoji
        )
    }
}
