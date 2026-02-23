# VTS (Voice Typing Studio) - Project Context

VTS is an open-source macOS menu bar application for global voice dictation. It allows users to transcribe speech into text in any application using AI providers like SiliconFlow, BigModel, and OpenAI.

## Project Overview

- **Purpose**: High-performance, AI-driven voice typing for macOS with intelligent refinement.
- **Tech Stack**: Swift (5.10+), SwiftUI, AVFoundation (Core Audio), Accessibility APIs.
- **Key Features**:
    - **Global Dictation**: Triggered via customizable hotkeys (e.g., Right Command, Fn key for Push-to-Talk).
    - **Intelligent Refinement**: AI-powered text optimization (removing filler words, correcting grammar).
    - **Voice Commands**: Spoken punctuation and formatting (e.g., "comma", "new paragraph").
    - **Accessibility Integration**: Injects text directly into the focused application's text field.
    - **Privacy-First**: API keys stored in Keychain, no telemetry, no audio storage.

## Architecture & Core Components

### 1. Application Layer (`VTSApp/`)
- **`VTSApp.swift`**: Entry point and central `AppState` management.
- **`StatusBarController.swift`**: Manages the menu bar icon and context menus.
- **`AppState.swift`**: The main coordinator for all services and state.

### 2. Audio & Transcription (`VTSApp/VTS/Services/`)
- **`CaptureEngine.swift`**: Handles low-level audio capture using `AVAudioEngine`.
- **`RestTranscriptionService.swift`**: Orchestrates non-streaming transcription requests.
- **`StreamingTranscriptionService.swift`**: Manages real-time streaming transcription.
- **`DeviceManager.swift`**: Microphone selection and priority logic.

### 3. Text Processing & Injection
- **`TextInjector.swift`**: Injects transcribed text using Accessibility APIs or Unicode typing simulation.
- **`TextRefinementService.swift`**: Calls LLMs to polish and refine transcribed text.
- **`VoiceCommandProcessor.swift`**: Parses spoken commands for punctuation and formatting.
- **`FillerWordFilter.swift`**: Removes hesitations (um, uh, etc.).

### 4. UI & Onboarding
- **`PreferencesView.swift`**: Comprehensive settings for providers, audio, and shortcuts.
- **`OnboardingView.swift`**: Guides users through API key setup and permission granting.

## Build and Run

### Prerequisites
- macOS 14.0 or later.
- Xcode 15.0+.
- Microphone and Accessibility permissions.

### Commands
- **Build**: `xcodebuild -project VTSApp.xcodeproj -scheme VTSApp build`
- **Clean**: `xcodebuild clean -project VTSApp.xcodeproj -scheme VTSApp`
- **Release (DMG)**: Run `./scripts/build-dmg.sh` (handles ad-hoc signing if no certificate is present).

## Development Conventions

- **State Management**: Uses `@StateObject` and `@Published` in `AppState` for global state.
- **Permissions**: Accessibility permission is critical for `TextInjector`. If injection fails, reset permissions in System Settings.
- **API Keys**: Managed via `APIKeyManager` using `KeychainAccess`. Never log or expose these.
- **Concurrency**: Extensive use of Swift Structured Concurrency (`Task`, `async/await`).
- **Testing**: Primarily manual using `TextInjectionTestView`. Focus on cross-application compatibility for text injection.

## Critical Files
- `CLAUDE.md`: Contains detailed developer notes and release engineering lessons.
- `Package.swift`: Defines SPM dependencies (`KeychainAccess`, `KeyboardShortcuts`).
- `VTSApp.entitlements`: Defines the app's sandbox and hardware access capabilities.
