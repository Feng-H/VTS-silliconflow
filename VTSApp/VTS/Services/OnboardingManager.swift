import Foundation
import Combine

@MainActor
public class OnboardingManager: ObservableObject {
    public static let shared = OnboardingManager()
    
    @Published public var isOnboardingCompleted = false
    @Published public var currentStep: OnboardingStep = .welcome
    @Published public var needsPermissionRepair = false
    @Published public var missingSteps: [OnboardingStep] = []
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboardingCompleted"
    
    private init() {
        loadOnboardingState()
    }
    
    private func loadOnboardingState() {
        isOnboardingCompleted = userDefaults.bool(forKey: onboardingCompletedKey)
    }
    
    func checkPermissions(with appState: AppState) {
        // Accessibility is critical for VTS to work
        let hasAccessibility = appState.restTranscriptionServiceInstance.injector.hasAccessibilityPermission
        let hasMic = appState.captureEngineService.permissionGranted
        
        var missing: [OnboardingStep] = []
        if !hasMic { missing.append(.microphone) }
        if !hasAccessibility { missing.append(.accessibility) }
        
        self.missingSteps = missing
        
        // If onboarding was completed but permissions are gone, we need repair
        if isOnboardingCompleted && !missing.isEmpty {
            self.needsPermissionRepair = true
            // Set current step to the first missing one
            if let firstMissing = missing.first {
                self.currentStep = firstMissing
            }
        } else {
            self.needsPermissionRepair = false
        }
    }
    
    public func completeOnboarding() {
        isOnboardingCompleted = true
        needsPermissionRepair = false
        userDefaults.set(true, forKey: onboardingCompletedKey)
        print("🎉 Onboarding completed successfully!")
    }
    
    public func resetOnboarding() {
        isOnboardingCompleted = false
        needsPermissionRepair = false
        currentStep = .welcome
        userDefaults.removeObject(forKey: onboardingCompletedKey)
        print("🔄 Onboarding reset - will show on next app launch")
    }
    
    public func nextStep() {
        if needsPermissionRepair {
            // In repair mode, move to next missing step or complete
            if let currentIndex = missingSteps.firstIndex(of: currentStep),
               currentIndex < missingSteps.count - 1 {
                currentStep = missingSteps[currentIndex + 1]
            } else {
                completeOnboarding()
            }
        } else {
            currentStep = currentStep.next()
        }
    }
    
    public func previousStep() {
        if needsPermissionRepair {
            if let currentIndex = missingSteps.firstIndex(of: currentStep),
               currentIndex > 0 {
                currentStep = missingSteps[currentIndex - 1]
            }
        } else {
            currentStep = currentStep.previous()
        }
    }
}

public enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case microphone = 1
    case apiKey = 2
    case accessibility = 3
    case notifications = 4
    case test = 5
    case completion = 6
    
    public func next() -> OnboardingStep {
        let allCases = OnboardingStep.allCases
        if let currentIndex = allCases.firstIndex(of: self),
           currentIndex < allCases.count - 1 {
            return allCases[currentIndex + 1]
        }
        return self
    }
    
    public func previous() -> OnboardingStep {
        let allCases = OnboardingStep.allCases
        if let currentIndex = allCases.firstIndex(of: self),
           currentIndex > 0 {
            return allCases[currentIndex - 1]
        }
        return self
    }
    
    public var title: String {
        switch self {
        case .welcome:
            return "Welcome to VTS"
        case .microphone:
            return "Microphone Access"
        case .apiKey:
            return "AI Provider Setup"
        case .accessibility:
            return "Text Insertion Access"
        case .notifications:
            return "Notifications"
        case .test:
            return "Test Your Setup"
        case .completion:
            return "All Set!"
        }
    }
    
    public var description: String {
        switch self {
        case .welcome:
            return "Your AI-powered voice transcription assistant"
        case .microphone:
            return "Required for recording audio"
        case .apiKey:
            return "Connect your AI provider for transcription"
        case .accessibility:
            return "Required for automatic text insertion"
        case .notifications:
            return "Stay informed about transcription status"
        case .test:
            return "Let's test your voice transcription"
        case .completion:
            return "You're ready to start using VTS!"
        }
    }
    
    public var isOptional: Bool {
        switch self {
        case .notifications:
            return true
        default:
            return false
        }
    }
    
    @MainActor
    func canProceed(with appState: AppState) -> Bool {
        switch self {
        case .microphone:
            return appState.captureEngineService.permissionGranted
        case .apiKey:
            return appState.apiKeyManagerService.hasAPIKey(for: appState.selectedProvider)
        case .accessibility:
            return appState.restTranscriptionServiceInstance.injector.hasAccessibilityPermission
        default:
            return true
        }
    }
    
    @MainActor
    func proceedBlockerMessage(with appState: AppState) -> String? {
        return canProceed(with: appState) ? nil : {
            switch self {
            case .microphone:
                return "Microphone permission is required to continue"
            case .apiKey:
                return "API key setup is required to continue"
            case .accessibility:
                return "Accessibility permission is required for auto-insertion"
            default:
                return nil
            }
        }()
    }
}
