// Presentation/Home/EntryDisplayModel.swift
// QuietJournal — Presentation/Home

import Foundation

struct EntryDisplayModel {
    let title:       String   // título da entrada
    let bodyPreview: String   // primeiros ~80 chars do body
    let subtitle:    String   // data formatada
    let accessory:   String   // emoji puro do humor
}
