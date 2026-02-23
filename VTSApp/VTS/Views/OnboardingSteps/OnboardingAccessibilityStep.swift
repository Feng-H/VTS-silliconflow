import SwiftUI

struct OnboardingAccessibilityStep: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var hasPermission = false
    @State private var animateIcon = false
    
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
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "text.insert")
                        .font(.system(size: 50))
                        .foregroundColor(accessibilityColor)
                        .rotationEffect(.degrees(animateIcon ? 360 : 0))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: animateIcon)
                }
                
                HStack {
                    Text(onboardingManager.needsPermissionRepair ? "Repair Accessibility Access" : "Text Insertion Access")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Text(onboardingManager.needsPermissionRepair ? 
                     "macOS often resets Accessibility permissions after updates. Please toggle VTS off and on, or remove and re-add it." :
                     "Enable automatic text insertion to seamlessly add transcribed text into any application")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 500)
            }
            
            // Main content
            VStack(spacing: 24) {
                // Permission status
                AccessibilityPermissionCard(
                    hasPermission: hasPermission,
                    title: "Accessibility Permission",
                    grantedMessage: "✅ Accessibility access granted! Text will be automatically inserted into applications.",
                    deniedMessage: "⚠️ Accessibility access not enabled. Auto-insertion will not work.",
                    color: accessibilityColor
                )
                
                // Important fix instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("💡 How to fix 'Granted but not working':")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If VTS is already enabled in settings but still doesn't insert text:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        BenefitRow(
                            icon: "1.minus.circle.fill",
                            title: "Remove from list",
                            description: "Select VTS in System Settings and click the '-' button."
                        )
                        BenefitRow(
                            icon: "2.plus.circle.fill",
                            title: "Re-add the app",
                            description: "Click '+' and select VTS from your Applications folder."
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Action buttons
                VStack(spacing: 12) {
                    if !hasPermission || onboardingManager.needsPermissionRepair {
                        Button(action: requestAccessibilityPermission) {
                            Label("Open Accessibility Settings", systemImage: "text.insert")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Find 'VTS' in the list. If it's already there, toggle it OFF and ON again.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxWidth: 600)
            
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
    
    private func requestAccessibilityPermission() {
        textInjector.requestAccessibilityPermission()
    }
}
