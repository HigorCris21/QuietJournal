// Core/AppConstants.swift
// QuietJournal — Core

import UIKit

// Constantes globais do app — evita strings e valores mágicos espalhados pelo código.

enum AppConstants {

    // MARK: - Firestore Paths

    enum Firestore {
        static let users   = "users"
        static let entries = "entries"
    }

    // MARK: - Colors

    enum Colors {
        static let primary    = UIColor(named: "PrimaryColor")
        static let background = UIColor(named: "BackgroundColor")
        static let text       = UIColor(named: "TextColor")
    }

    // MARK: - Strings — Auth

    enum Strings {
        enum Auth {
            static let loginTitle      = "Entrar"
            static let registerTitle   = "Criar conta"
            static let emailPlaceholder    = "E-mail"
            static let passwordPlaceholder = "Senha"
            static let errorInvalidCredentials = "E-mail ou senha incorretos."
            static let errorUserNotFound       = "Usuário não encontrado."
            static let errorEmailInUse         = "Este e-mail já está em uso."
            static let errorNetwork            = "Sem conexão. Tente novamente."
            static let errorUnknown            = "Algo deu errado. Tente novamente."
        }

        enum Journal {
            static let newEntryTitle  = "Nova entrada"
            static let editEntryTitle = "Editar entrada"
            static let deleteConfirm  = "Deseja deletar esta entrada?"
        }
    }
}
