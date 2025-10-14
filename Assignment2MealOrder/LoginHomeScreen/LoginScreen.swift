import SwiftUI

// MARK: - LoginScreen
// This is the entry point for the app.
// It provides a login form with username and password fields,
// validates credentials, and navigates to either the Admin or User dashboard.
struct LoginScreen: View {
    // MARK: - State variables
    @State private var username: String = ""        // Stores entered username
    @State private var password: String = ""        // Stores entered password
    @State private var loginMessage: String = ""    // Stores error/feedback messages
    @State private var navigateToAdmin = false      // Controls navigation to AdminDashboard
    @State private var navigateToUser = false       // Controls navigation to UserDashboard
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient (light blue theme for a welcoming look)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.cyan.opacity(0.4),
                        Color.white.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // MARK: App logo and title
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .shadow(radius: 6)
                    
                    Text("iMealOrder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Delicious meals, just a tap away")
                        .font(.subheadline)
                        .foregroundColor(.blue.opacity(0.8))
                    
                    // MARK: Login card
                    VStack(spacing: 20) {
                        // Username field
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                            .autocapitalization(.none) // prevent auto-capitalization
                        
                        // Password field (secure entry)
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                        
                        // Sign In button
                        Button(action: handleLogin) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue) // matches theme
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                        }
                        
                        // Show login error message if present
                        if !loginMessage.isEmpty {
                            Text(loginMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2)) // semi-transparent card
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)
                }
            }
            // Reset fields when the view appears
            .onAppear {
                username = ""
                password = ""
                loginMessage = ""
            }
            // Navigation destinations triggered by state
            .navigationDestination(isPresented: $navigateToAdmin) {
                AdminDashboard()
            }
            .navigationDestination(isPresented: $navigateToUser) {
                UserDashboard()
            }
        }
    }
    
    // MARK: - Login Logic
    // Validates credentials and sets navigation flags accordingly
    private func handleLogin() {
        if username.isEmpty || password.isEmpty {
            // Both fields must be filled
            loginMessage = "Please enter both username and password."
        } else if username == "admin" && password == "1234" {
            // Hardcoded admin credentials
            loginMessage = ""
            navigateToAdmin = true
        } else if username == "user" && password == "1234" {
            // Hardcoded user credentials
            loginMessage = ""
            navigateToUser = true
        } else {
            // Invalid credentials
            loginMessage = "Invalid credentials."
        }
    }
}
