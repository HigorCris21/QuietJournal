// Core/Coordinator.swift
// QuietJournal — Core

import UIKit

// Protocolo base para todos os Coordinators do app.
// Define o contrato mínimo que qualquer fluxo de navegação deve cumprir.

protocol Coordinator: AnyObject {

    // Cada Coordinator gerencia seus filhos
    var childCoordinators: [Coordinator] { get set }

    // Ponto de entrada — inicia o fluxo de navegação
    func start()
}

// MARK: - Helpers

extension Coordinator {

    // Adiciona um coordinator filho ao iniciar um novo fluxo
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    // Remove um coordinator filho ao encerrar um fluxo
    // Evita memory leak
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
