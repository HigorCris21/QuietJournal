import Foundation

enum HomeError: Error {
    case deleteFailed
    case logoutFailed
    case unknown
}

extension HomeError {

    var message: String {
        switch self {
        case .deleteFailed:
            return "Erro ao deletar entrada"
        case .logoutFailed:
            return "Erro ao sair"
        case .unknown:
            return "Erro inesperado"
        }
    }
}
