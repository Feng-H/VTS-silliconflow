# VTS - Voice Typing Studio
<p align="center">
  <img src="public/logo.png" alt="VTS Logo" width="150">
  <br>
  <strong>The open-source macOS dictation replacement you've been waiting for! 🚀</strong>
</p>

> **🔊 Turn on your sound!** This demo includes audio to showcase the real-time transcription experience.

https://github.com/user-attachments/assets/bc77c14b-863c-418f-8564-175d6300ce2b

<p align="center">
  <strong>🚀 Sub-second dictation. BYO key. Types where your cursor is.</strong>
</p>

---

<p align="center">
  <a href="https://github.com/j05u3/VTS/releases/latest">
    <img src="https://img.shields.io/badge/📦%20Download%20DMG-Latest%20Release-brightgreen?style=for-the-badge&logo=apple&logoColor=white&labelColor=000000&color=007ACC" alt="Download DMG" width="300">
  </a>
</p>

<p align="center">
  <strong>Or install with Homebrew:</strong>
</p>

```bash
brew install j05u3/tap/voice-typing-studio
```

<p align="center">
  <!-- Social and Community Badges -->
  <a href="https://github.com/j05u3/VTS/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/j05u3/VTS?style=for-the-badge&logo=github&color=gold"></a>
  <a href="https://github.com/j05u3/VTS/network/members"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/j05u3/VTS?style=for-the-badge&logo=github&color=blueviolet"></a>
  <br>
  <!-- Status and Release Badges -->
  <a href="https://github.com/j05u3/VTS/releases/latest"><img alt="Latest Release" src="https://img.shields.io/github/v/release/j05u3/VTS?style=for-the-badge&color=brightgreen"></a>
  <a href="https://github.com/j05u3/VTS/releases"><img alt="GitHub Downloads" src="https://img.shields.io/github/downloads/j05u3/VTS/total?style=for-the-badge&logo=github&color=success"></a>
  <a href="https://opensource.org/licenses/MIT"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge"></a>
  <br>
  <!-- Development Activity Badges -->
  <a href="https://github.com/j05u3/VTS/actions/workflows/build-and-distribute.yml"><img alt="Build Status" src="https://img.shields.io/github/actions/workflow/status/j05u3/VTS/build-and-distribute.yml?style=for-the-badge&logo=githubactions"></a>
  <a href="https://github.com/j05u3/VTS/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/j05u3/VTS?style=for-the-badge&logo=github&color=red"></a>
  <a href="https://github.com/j05u3/VTS/pulls"><img alt="GitHub Pull Requests" src="https://img.shields.io/github/issues-pr/j05u3/VTS?style=for-the-badge&logo=github&color=yellow"></a>
  <br>
  <!-- Platform Badge -->
  <a href="https://developer.apple.com/macos/"><img alt="Platform" src="https://img.shields.io/badge/platform-macOS%2014.0%2B-blue?style=for-the-badge&logo=apple"></a>
</p>

---

Transform your voice into text instantly with the power of **SiliconFlow** and **BigModel** APIs. Say goodbye to macOS dictation limitations and hello to lightning-fast, accurate transcription with your own custom hotkeys! ⚡️

## 📋 Table of Contents

- [Why Choose VTS?](#-why-choose-vts)
- [API Key Setup](#api-key-setup)
- [Usage Guide](#-usage-guide)
  - [Basic Transcription](#basic-transcription)
  - [Advanced Features](#advanced-features)
- [Privacy & Security](#-privacy--security)
- [Troubleshooting](#%EF%B8%8F-troubleshooting)
- [Development](#%E2%80%8D-development)
  - [Requirements](#development-requirements)
  - [Building from Source](#building-from-source)
  - [Architecture](#architecture)
- [License](#-license)

## ✨ Why Choose VTS?

- 🤖 **AI-Powered Accuracy**: Leverage SiliconFlow and BigModel models for superior transcription
- 🔑 **Your Keys, Your Control**: Bring your own API keys - no subscriptions, no limits
- 🔄 **Drop-in Replacement**: Works exactly like macOS dictation, but better!
- ⌨️ **Push-to-Talk**: Hold **Right Command** (⌘) to record instantly
- 🎯 **Smart Device Management**: Intelligent microphone priority with seamless fallback
- 💬 **Context-Aware**: Custom system prompt boosts accuracy for your specific needs
- 🔓 **100% Open Source**: Full transparency, community-driven, modify as you wish

## API Key Setup

After installing VTS, you'll need an API key from one of these providers:

- **SiliconFlow**: [Get your API key here](https://cloud.siliconflow.cn/account/ak)
- **BigModel**: [Get your API key here](https://open.bigmodel.cn/usercenter/apikeys)

*Only one API key is required - choose the provider you prefer!*

**Requirements:**
- **macOS 14.0+** (Apple Silicon & Intel supported)
- **API key** from SiliconFlow or BigModel

## 📖 Usage Guide

### Basic Transcription
1. **Choose Provider**: Select SiliconFlow or BigModel from the dropdown
2. **Select Model**: Pick available models (e.g., SenseVoiceSmall, glm-4-voice)
3. **Enter API Key**: Paste your API key in the secure field
4. **Start Recording**: Press and **HOLD** the **Right Command** (⌘) key and speak
5. **View Results**: Release the key to see real-time transcription inserted into the application you're using
6. **(Optional) Copy**: Use buttons to copy the transcript

### Advanced Features

#### Microphone Priority Management
- **View Available Devices**: See all connected microphones with system default indicators
- **Set Priority Order**: Add devices to priority list with + buttons
- **Automatic Fallback**: App automatically uses highest-priority available device
- **Real-time Switching**: Seamlessly switches when preferred devices connect/disconnect
- **Remove from Priority**: Use − buttons to remove devices from priority list

#### Custom System Prompts
- Add context-specific prompts to improve transcription accuracy
- Examples: "Medical terminology", "Technical jargon", "Names: John, Sarah, Mike"
- Prompts help the AI better understand domain-specific language

## 🔒 Privacy & Security

- **No audio storage**: Audio is processed in real-time, never stored locally
- **API keys are safe**: Keys are stored in Keychain
- **TLS encryption**: All API communication uses HTTPS
- **Microphone permission**: Explicit user consent required for audio access
- **Basic telemetry**: We collect minimal usage analytics

## 🛠️ Troubleshooting

### Common Issues
- **Microphone Permission Denied**: Check System Settings > Privacy & Security > Microphone
- **No Microphones Found**: Click "Refresh" in the Microphone Priority section
- **Wrong Microphone Active**: Set your preferred priority order or check device connections
- **App Not Responding to Hotkey**: Ensure accessibility permissions are granted when prompted

---

## 👩‍💻 Development

*This section is for developers who want to build VTS from source or contribute to the project.*

### Development Requirements
- **macOS 14.0+** (Apple Silicon & Intel supported)
- **Xcode 15+** for building
- **API key** from SiliconFlow or BigModel for testing

### Building from Source

1. **Clone the repository:**
```bash
git clone https://github.com/j05u3/VTS.git
cd VTS
```

2. **Open in Xcode:**
```bash
open VTSApp.xcodeproj
```

3. **Build and run:**
   - In Xcode, select the **VTSApp** scheme
   - Build and run with **⌘R**
   - Grant microphone permission when prompted

#### Command Line Building

```bash
# Build via command line
xcodebuild -project VTSApp.xcodeproj -scheme VTSApp build
```

### Architecture

VTS follows a clean, modular architecture:

- **CaptureEngine**: Handles audio capture using AVAudioEngine with Core Audio device management
- **DeviceManager**: Manages microphone priority lists and automatic device selection
- **TranscriptionService**: Orchestrates streaming transcription with provider abstraction
- **STTProvider Protocol**: Clean interface allowing easy addition of new providers
- **Modern SwiftUI**: Reactive UI with proper state management and real-time updates

### Testing

Currently, VTS includes manual testing capabilities through the built-in Text Injection Test Suite accessible from the app's interface. This allows you to test text insertion functionality across different applications.

Automated unit tests are planned for future releases.

### Development Troubleshooting

#### Accessibility Permissions (Development)
- **Permission Not Updating**: During development/testing, when the app changes (rebuild, code changes), macOS treats it as a "new" app
- **Solution**: Remove the old app entry from System Settings > Privacy & Security > Accessibility, then re-grant permission
- **Why This Happens**: Each build gets a different signature, so macOS sees it as a different application
- **Quick Fix**: Check the app list in Accessibility settings and remove any old/duplicate VTS entries

#### Testing Onboarding Flow
- **Reset App State**: To test the complete onboarding flow, change the `PRODUCT_BUNDLE_IDENTIFIER` in Xcode project settings
- **Why This Works**: Changing the bundle identifier creates a "new" app from macOS perspective, resetting all permissions and app state
- **Most Reliable Method**: This is more reliable than clearing UserDefaults and ensures a clean onboarding test including all system permissions

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
