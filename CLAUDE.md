# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Run

- **Build Project**: `xcodebuild -project VTSApp.xcodeproj -scheme VTSApp build`
- **Open in Xcode**: `open VTSApp.xcodeproj`
- **Run**: Best run via Xcode (CMD+R) due to microphone permissions, accessibility API access, and entitlement signing.
- **Clean**: `xcodebuild clean -project VTSApp.xcodeproj -scheme VTSApp`
- **Dependencies**: Managed via Swift Package Manager in `Package.swift` (KeychainAccess, KeyboardShortcuts, Sparkle).

## Architecture

VTS (Voice Typing Studio) is a macOS menu bar application for global voice dictation.

### Core Components
- **VTSApp**: Main entry point.
- **StatusBarController**: Manages the menu bar interface and app lifecycle.
- **CaptureEngine**: Handles audio capture using `AVAudioEngine` and Core Audio.
- **DeviceManager**: Manages microphone priority and fallback selection.
- **TextInjector**: Handles inserting text into the active application using Accessibility APIs.

### Transcription System
- **Services**:
  - `RestTranscriptionService`: Handles non-streaming transcription requests.
  - `StreamingTranscriptionService`: Orchestrates streaming transcription.
- **Providers**: Implements `RestSTTProvider` or `StreamingSTTProvider` protocols.
  - Supported: OpenAI (Rest/Streaming), Groq, Deepgram, SiliconFlow, BigModel.
- **Models**: `TranscriptionModels.swift`, `StreamingModels.swift`, `RealtimeSession`.

### UI Layer
- **SwiftUI**: Used for all views.
- **PreferencesView**: Main settings interface.
- **Onboarding**: Series of steps (`OnboardingWelcomeStep`, `OnboardingAPIKeyStep`, etc.) managed by `OnboardingManager`.
- **Visualizers**: `AudioLevelView`.

### Data & Services
- **KeychainAccess**: Secure storage for API keys.
- **UserDefaults**: Application preferences.
- **AnalyticsService**: Manages privacy-aware telemetry.
- **SparkleUpdaterManager**: Handles app updates.
- **ModifierKeyMonitor**: Monitors modifier keys for shortcuts.

## Testing

- **Manual Testing**: Primary method. Use the "Text Injection Test Suite" (`TextInjectionTestView`) to verify text insertion.
- **Unit Tests**: Currently not implemented.
- **Integration**: To test the full onboarding flow, change `PRODUCT_BUNDLE_IDENTIFIER` in Xcode to reset system-level permissions state.

## Development Notes

- **Permissions**: Requires `Microphone` access and `Accessibility` permissions (to simulate keystrokes/inject text).
- **Entitlements**: `VTSApp.entitlements` defines App Sandbox and hardware access.
- **Accessibility Reset**: When rebuilding locally, macOS may treat the app as new. Remove and re-add VTS in `System Settings > Privacy & Security > Accessibility` if text injection fails.
- **Malware Safety**: This app uses Accessibility APIs to inject text. This is legitimate behavior for a dictation app but can be flagged by security tools.
