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

## Release & CI/CD Lessons Learned

### Ad-hoc Signing & No-Certificate Release
When releasing a macOS app without an Apple Developer Program membership ($99/year), specific workarounds are needed for CI/CD:

1.  **Xcode Archive**: `xcodebuild archive` requires a development team. If none is available, force unsigned build args: `CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`.
2.  **Export**: `xcodebuild -exportArchive` fails without a valid Team ID even with manual/ad-hoc settings.
    - **Fix**: Skip `xcodebuild -exportArchive` entirely. Manually `cp -R` the `.app` bundle from `.xcarchive/Products/Applications/` to the export directory.
3.  **Ad-hoc Signing**: Use `codesign --force --deep -s - VTS.app` to apply a local ad-hoc signature. This allows the app to run (user may need to right-click -> Open).
4.  **DMG Creation**: `sindresorhus/create-dmg` often fails in CI if no signing identity is found.
    - **Fix**: Use native `hdiutil create` command instead. It's robust and doesn't require signing identities.
5.  **Shell Scripting**: Be careful when capturing function output: `var=$(func)`. If `func` prints logs to `stdout`, they pollute the return value. Always redirect logs to `stderr` (`>&2`).
6.  **Keychain**: In CI, skip `security create-keychain` if no certificate secret (`BUILD_CERTIFICATE_BASE64`) is present.
