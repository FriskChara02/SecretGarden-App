<div align="center">

# ❀ Secret Garden ❀

**A Production-Grade iOS Manga & Novel Reader App**  
Built with Swift & SwiftUI following industry-standard practices

![CI](https://github.com/FriskChara02/SecretGarden-App/actions/workflows/ci.yml/badge.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.10%2B-orange)
![UI](https://img.shields.io/badge/UI-SwiftUI-informational)
![Status](https://img.shields.io/badge/status-in%20development-yellow)

</div>

> .ᐟ.ᐟ.ᐟ **Educational Project · Work in Progress.** The application currently runs on **mock data**, with no real backend server connection or App Store distribution yet. This repository contains zero copyrighted comic or novel content.

## ⌯⌲ Screenshots

> ⌛︎ **Updating soon...** High-resolution previews and screenshots of the application features will be published here in upcoming releases.

## ❀ Features

- **Authentication**: Sign In, Sign Up, Forgot Password, Google OAuth, Guest Mode (read without signing in)
- **Home Hub**: Banners, Continue Reading, Random Manga Discovery, Recent Updates, Leaderboards, Community Highlights
- **Search & Filter**: Keyword search (debounce, history) and **Advanced Filter** with Include/Exclude tag management
- **Detail & Reader**: Vertical continuous scrolling, lazy image loading with caching, chapter selection, Manga lists (Plan to Read / Following / Completed / Dropped)
- **Community**: Story and chapter-level comments, likes, replies, group/author following, violation reporting
- **Profile & Settings**: Custom profile page, avatar upload, account management, notifications, block list, Dark Mode
- **Compliance**: Age verification gate (16+), Community Rules, Terms of Service, Privacy Policy
- **Accessibility**: Full VoiceOver integration and Dynamic Type support

## ✦︎ Tech Stack

| Domain | Technology / Library |
|---|---|
| Language / UI | Swift, SwiftUI |
| Architecture | MVVM, Repository Pattern, Coordinator, Dependency Injection |
| Concurrency | async/await, actor |
| Storage | Keychain (token), SwiftData (search history), UserDefaults |
| Dependencies | [Factory](https://github.com/hmlongco/Factory) (DI), [Nuke](https://github.com/kean/Nuke) (image caching) |
| Code Quality | SwiftLint, SwiftFormat (Build Tool Plugin) |
| Testing | XCTest, XCUITest |
| CI/CD | GitHub Actions |

## 𓍝 Architecture

The project is structured into **modular local Swift Packages**, with dependency boundaries enforced by the compiler. Feature modules **do not import each other**, only the main App target connects them together (Composition Root).

### Layer Hierarchy

- **App Layer (`SecretGarden`)**: Composition Root, App Launch, Root Navigation Routing.
- **Feature Layer (`*Feature`)**: `AuthFeature`, `HomeFeature`, `SearchFeature`, `SocialFeature` (UI Views, ViewModels, Feature Coordinators).
- **Domain & Data Layer (`Repositories`)**: Repository protocols and concrete implementations, data mapping, caching strategy.
- **Core Services Layer**:
  - `CoreNetworking`: `APIClient`, `Endpoint`, `AuthInterceptor`, Token Refresh.
  - `CoreStorage`: `Keychain` manager, `SwiftData` context for search history.
  - `CoreArchitecture`: Base ViewModel protocols, Coordinator protocols, Shared App States.
- **Foundation Layer**:
  - `DesignSystem`: Color palettes, Typography, Reusable Components, Legal Views.
  - `CoreModels`: Pure Domain Entities (Zero dependencies).

**Data Flow:**  
`View` ➔ `ViewModel` ➔ `RepositoryProtocol` ➔ `Repository` ➔ `APIClient` ⇄ `AuthInterceptor` ➔ `Keychain`

## ☕︎ Getting Started

**Prerequisites:** macOS with Xcode 26.6 or higher (developed on Xcode 27), iOS Simulator 17+.

```bash
git clone https://github.com/FriskChara02/SecretGarden-App.git
cd SecretGarden-App
open SecretGarden.xcodeproj

```

1. Select the **`SecretGarden-Dev`** scheme.
2. Select an iOS Simulator (e.g., iPhone 17 Pro) and press **Run (⌘R)**.
3. On first build, when Xcode prompts to trust SwiftLint/SwiftFormat plugins, select **Trust & Enable**.

### Environment Configuration

Environments are configured separately via `.xcconfig` files in the `Configs/` directory:

| Scheme | Environment | Data Source |
| --- | --- | --- |
| `SecretGarden-Dev` | development | Mock |
| `SecretGarden-Staging` | staging | Mock |
| `SecretGarden-Production` | production | Live API (currently placeholder endpoint) |

> Values in `.xcconfig` are currently **placeholders** and contain no secrets. Production values are injected via GitHub Secrets in CI.

## 🎐 Testing

```bash
xcodebuild test \
  -project SecretGarden.xcodeproj \
  -scheme SecretGarden-Dev \
  -testPlan SecretGarden-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -enableCodeCoverage YES

```

Or press **⌘U** in Xcode. The suite covers Unit Tests (Networking, Auth, Repository, ViewModel, Coordinator, Storage) and UI Tests (Auth flow, Search flow).

## ✧ CI/CD

| Workflow | Trigger | Description |
| --- | --- | --- |
| **CI** (`ci.yml`) | Push to `main`, Pull Requests | Build project, run all test suites, report coverage |
| **Release Build** (`release-build.yml`) | Manual trigger, or push tag `v*` | Archive Release-Production (unsigned), verify 0 warnings and correct environment, create GitHub Release |

## ⚛︎ Project Structure

```
SecretGarden-App/
├── SecretGarden/          # App target (Composition Root, Navigation)
├── SecretGardenTests/     # Unit Test suite
├── SecretGardenUITests/   # UI Test suite
├── Packages/              # Local Swift Packages
│   ├── CoreModels/        # Domain models (zero dependencies)
│   ├── CoreNetworking/    # APIClient, AuthInterceptor, Endpoint
│   ├── CoreStorage/       # Keychain, SwiftData
│   ├── CoreArchitecture/  # Base ViewModel, Coordinator, shared state
│   ├── DesignSystem/      # Colors, typography, components, legal
│   ├── Repositories/      # Real and Mock Repositories
│   ├── AuthFeature/
│   ├── HomeFeature/
│   ├── SearchFeature/
│   └── SocialFeature/
├── Configs/               # .xcconfig files per environment
├── docs/                  # Documentation, performance reports, App Privacy Label
└── .github/workflows/     # CI/CD pipelines

```

## ‪‪❤︎‬ Known Limitations‪‪

* No real backend connection, all data is served via mock responses
* Google OAuth is not verified with a production Client ID
* Select ViewModels (Home, Social, Profile) are pending Unit Test coverage expansion

## ⛩ Contribution Guidelines

* Follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `ci:`
* Build every feature on a dedicated branch (`feat/...`) and open a Pull Request, CI must pass before merging
* Resolve all SwiftLint warnings before submitting code for review

---

<div align="center">

Crafted with ❤︎ by **FriskChara02** · Inspired by **Yurineko - Sự dịu dàng cuối cùng**

</div>
