import Foundation

enum HomeState {
    case idle
    case loading
    case loaded([JournalEntry])
    case empty
    case error(HomeError)
}
