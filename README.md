# 📓 QuietJournal

> Um diário pessoal iOS minimalista, seguro e em tempo real — construído com Clean Architecture, MVVM e Firebase.

---

## 📖 Sobre o Projeto

**QuietJournal** é um aplicativo iOS nativo de diário pessoal que permite registrar pensamentos, sentimentos e o humor do dia de forma simples e privada. As entradas são sincronizadas em tempo real via Firestore, garantindo que o conteúdo esteja sempre disponível e atualizado.

O projeto foi desenvolvido com foco em **boas práticas de arquitetura de software**, servindo tanto como aplicativo funcional quanto como referência de implementação de Clean Architecture + MVVM em Swift/UIKit sem storyboards.

---

## ✨ Funcionalidades

- 🔐 **Autenticação** — Cadastro e login com e-mail/senha via Firebase Auth
- 📝 **CRUD de Entradas** — Criar, visualizar, editar e excluir entradas do diário
- 😊 **Registro de Humor** — Marcação de mood por entrada (Feliz, Neutro, Triste)
- ⚡ **Tempo Real** — Sincronização instantânea via Firestore `AsyncStream`
- 🌙 **Dark Mode** — Suporte nativo via Asset Catalog (cores adaptativas)
- 🧪 **Testável por Design** — Camadas desacopladas com Protocols + Mocks

---

## 🏛️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com separação em camadas bem definidas, combinado ao padrão **MVVM** na camada de Apresentação e ao padrão **Coordinator** para navegação.

```
QuietJournal/
├── Application/          # Ponto de entrada — AppDelegate + AppCoordinator
├── Core/                 # Infraestrutura compartilhada
│   ├── Coordinator.swift # Protocolo base de navegação
│   └── Extensions/       # UITextView+Placeholder, String+Validation, AppConstants
├── Domain/               # 💡 Regras de negócio puras (sem dependências externas)
│   ├── Models/           # JournalEntry, Mood
│   ├── UseCases/         # GetEntries, CreateEntry, UpdateEntry, DeleteEntry
│   ├── Repositories/     # JournalRepositoryProtocol
│   ├── Services/         # AuthServiceProtocol, JournalRead/WriteServiceProtocol
│   └── Errors/           # AuthError, EntryError, HomeError
├── Data/                 # Implementações concretas (Firebase)
│   ├── Services/         # AuthService, JournalReadService, JournalWriteService
│   └── Mappers/          # JournalEntryMapper (Firestore ↔ Domain)
├── Presentation/         # UI — ViewControllers, ViewModels, Coordinators
│   ├── Auth/             # Login + Register (ViewController + ViewModel + Coordinator)
│   └── Home/             # Lista de entradas + Editor
└── Mocks/                # Mocks para testes (MockAuthService, JournalEntry+Mock)
```

### Fluxo de Dados

```
ViewController  ──▶  ViewModel  ──▶  UseCase  ──▶  Repository Protocol
      ▲                  │                               │
      └──── callback ────┘                          ServiceProtocol
                                                         │
                                                    Firebase (Data)
```

### Padrões Utilizados

| Padrão | Onde é aplicado |
|---|---|
| **MVVM** | Toda a camada Presentation |
| **Coordinator** | Navegação entre fluxos (Auth, Home) |
| **Repository** | Abstração de acesso a dados |
| **Use Case** | Encapsulamento de regras de negócio |
| **Protocol-Oriented** | Todas as dependências são injetadas via protocolo |
| **Dependency Injection** | Injeção via `init` em toda a cadeia |

---

## 🛠️ Tecnologias

| Tecnologia | Uso |
|---|---|
| **Swift 5.9+** | Linguagem principal |
| **UIKit** | Interface programática (sem Storyboards) |
| **Swift Concurrency** | `async/await`, `AsyncStream`, `Task` |
| **Firebase Auth** | Autenticação de usuários |
| **Cloud Firestore** | Banco de dados em tempo real |
| **XCTest** | Testes unitários e de UI |

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- Xcode 15+
- iOS 16+ (target mínimo)
- Conta Firebase (gratuita)
- CocoaPods ou Swift Package Manager

### Configuração

**1. Clone o repositório**
```bash
git clone https://github.com/seu-usuario/QuietJournal.git
cd QuietJournal
```

**2. Configure o Firebase**

- Acesse o [Firebase Console](https://console.firebase.google.com) e crie um projeto
- Adicione um app iOS com o bundle ID do projeto
- Baixe o arquivo `GoogleService-Info.plist` e adicione à raiz do target no Xcode
- Ative **Authentication** (E-mail/Senha) e **Cloud Firestore** no console

**3. Instale as dependências**

Via Swift Package Manager (recomendado):
```
File → Add Package Dependencies → https://github.com/firebase/firebase-ios-sdk
```
Adicione os produtos: `FirebaseAuth` e `FirebaseFirestore`

**4. Build & Run**
```
⌘ + R no Xcode com um simulador ou device iOS 16+
```

---

## 🗃️ Estrutura do Firestore

```
users/
  └── {uid}/
        └── entries/
              └── {entryId}/
                    ├── uid: String
                    ├── title: String
                    ├── body: String
                    ├── mood: String ("happy" | "neutral" | "sad")
                    ├── createdAt: Timestamp
                    └── updatedAt: Timestamp
```

As regras de segurança do Firestore devem garantir que cada usuário acesse somente seus próprios documentos:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/entries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Testes

Os testes unitários cobrem o `LoginViewModel` com os seguintes cenários:

- ❌ E-mail vazio → dispara erro sem chamar o serviço
- ❌ Senha vazia → dispara erro sem chamar o serviço
- ❌ E-mail inválido (sem @) → dispara erro de validação
- ✅ Credenciais válidas → dispara `onLoginSuccess`
- ❌ Credenciais inválidas (serviço falha) → dispara mensagem de erro correta
- ⏳ Loading → estado `true` antes da autenticação e `false` ao finalizar

Para rodar os testes:
```
⌘ + U no Xcode
```

---

## 📐 Princípios de Design

- **Sem Storyboards** — 100% código programático com Auto Layout
- **Source of Truth único** — `authService.currentUserID` determina o fluxo de navegação
- **Memory safe** — `[weak self]` em closures e remoção de listeners no `deinit`
- **Sem strings mágicas** — todas centralizadas em `AppConstants`
- **Erros tipados** — `AuthError`, `EntryError` e `HomeError` com mensagens de UI embutidas

---

## 👤 Autor

**Higor Lo Castro**
- GitHub: [@higorlocastro](https://github.com/higorlocastro)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
