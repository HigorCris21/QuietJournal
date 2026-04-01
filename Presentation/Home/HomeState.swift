//
//  HomeState.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 01/04/26.
//

import Foundation

enum HomeState {
    case idle
    case loading
    case loaded([EntryDisplayModel])
    case error(HomeError)
}
