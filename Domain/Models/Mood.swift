// Mood.swift
// QuietJournal — Domain/Models

// Enum representa os possíveis humores de uma entrada do diário.
// Usar enum garante que nunca existirá um valor inválido (SOLID - fechado para modificação)

enum Mood: String, CaseIterable, Codable {
    case happy   = "happy"
    case neutral = "neutral"
    case sad     = "sad"

    // Emoji visual para exibir na UI
    var emoji: String {
        switch self {
        case .happy:   return "😊"
        case .neutral: return "😐"
        case .sad:     return "😔"
        }
    }

    // Texto legível para exibir na UI
    var label: String {
        switch self {
        case .happy:   return "Feliz"
        case .neutral: return "Neutro"
        case .sad:     return "Triste"
        }
    }
}
