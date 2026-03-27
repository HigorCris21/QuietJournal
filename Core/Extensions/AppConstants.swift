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

        // Cores retornam UIColor (não-opcional) com fatalError explicativo.
        static let primary: UIColor = UIColor(named: "AccentColor") ?? {
            fatalError("AppConstants.Colors: 'AccentColor' não encontrado no Assets.xcassets")
        }()

        static let background: UIColor = UIColor(named: "BackgroundColor") ?? {
            fatalError("AppConstants.Colors: 'BackgroundColor' não encontrado no Assets.xcassets")
        }()

        static let text: UIColor = UIColor(named: "TextColor") ?? {
            fatalError("AppConstants.Colors: 'TextColor' não encontrado no Assets.xcassets")
        }()
    }

    // MARK: - Formatters

    enum Formatters {

        static let entryDate: DateFormatter = {
            let df = DateFormatter()
            df.dateStyle = .medium  // ex: 25 de mar. de 2026
            df.timeStyle = .short   // ex: 14:30
            df.locale    = Locale(identifier: "pt_BR")
            return df
        }()
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
            static let bodyPlaceholder = "Escreva sua entrada aqui..."
        }

        enum Cell {
            // Identificador da célula centralizado — uma string, um lugar.
            static let entryCell = "EntryCell"
        }
    }
}
