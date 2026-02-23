import SwiftUI

struct OnboardingAccessibilityStep: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var hasPermission = false
    @State private var animateIcon = false
    @State private var isResetting = false
    
    private var textInjector: TextInjector {
        appState.restTranscriptionServiceInstance.injector
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header section
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(accessibilityColor.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 40))
                        .foregroundColor(accessibilityColor)
                        .scaleEffect(animateIcon ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
                }
                
                Text(onboardingManager.needsPermissionRepair ? "Fix Text Insertion" : "Enable Text Insertion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(onboardingManager.needsPermissionRepair ? 
                     "macOS security sometimes blocks VTS after an update. Let's fix it automatically." :
                     "VTS needs permission to type text for you in other applications.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 500)
            }
            
            // Simplified Action Card
            VStack(spacing: 24) {
                if !hasPermission || onboardingManager.needsPermissionRepair {
                    VStack(spacing: 20) {
                        Text("Recommended Action")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            isResetting = true
                            textInjector.resetTCCPermissions()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isResetting = false
                            }
                        }) {
                            HStack {
                                if isResetting {
                                    ProgressView()
                                        .controlSize(.small)
                                        .padding(.trailing, 5)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                }
                                Text(isResetting ? "Resetting..." : "One-Click Fix & Open Settings")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .disabled(isResetting)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            StepInfoRow(icon: "1.circle", text: "Click the blue button above to reset the permission.")
                            StepInfoRow(icon: "2.circle", text: "When System Settings opens, find VTS in the list.")
                            StepInfoRow(icon: "3.circle", text: "Toggle the switch OFF and then ON again.")
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Permission Active")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("VTS is now ready to insert text for you.")
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                }
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
        .padding(.horizontal, 60)
        .onAppear {
            updatePermissionStatus()
            animateIcon = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            updatePermissionStatus()
        }
    }
    
    private var accessibilityColor: Color {
        hasPermission ? .green : .blue
    }
    
    private func updatePermissionStatus() {
        textInjector.updatePermissionStatus()
        hasPermission = textInjector.hasAccessibilityPermission
    }
}

struct StepInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.body.bold())
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
