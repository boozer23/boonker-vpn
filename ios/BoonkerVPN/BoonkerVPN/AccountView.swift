import SwiftUI

struct AccountView: View {
    let onLogout: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showLogin = false
    @State private var showPlans = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Email", value: "alex@example.com")
                    LabeledContent("Access code", value: "no86FQ2Bez")
                }
                Section("Subscription") {
                    LabeledContent("Plan", value: "Boonker Pro")
                    LabeledContent("Renews", value: "30 Jan 2027")
                    Button("Change plan") { showPlans = true }
                }
                Section {
                    Button("Sign in with another account") { showLogin = true }
                    Button("Sign out", role: .destructive) {
                        onLogout()
                        dismiss()
                    }
                }
            }
            .navigationTitle("My account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
        .sheet(isPresented: $showLogin) {
            LoginView { showLogin = false }
        }
        .sheet(isPresented: $showPlans) { PlansView() }
    }
}
