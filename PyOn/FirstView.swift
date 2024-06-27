//  FirstView.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

struct FirstView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = LoginViewModel()
    @State private var shouldShowRegistration = false // Управляет переходом к RegistrationView
    
    private let logoSize: CGFloat = 100
    private let buttonWidth: CGFloat = 220
    private let buttonHeight: CGFloat = 60
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 20) {
                Spacer()
                logoView
                welcomeText
                loginText
                loginFields
                loginButton
                errorMessageView // Отображение сообщения об ошибке
                
                registrationButton
                
                Spacer()
            }
            .padding()
            
            if viewModel.isLoginActive {
                loadingIndicator // Показывает загрузочный индикатор
            }
            
            if viewModel.isLoggedIn {
                ContentView(login: viewModel.login) // Переход на следующий экран при успешном входе
            }
        }
        .fullScreenCover(isPresented: $shouldShowRegistration) {
            RegistrationView()
        }
    }
    
    private var backgroundView: some View {
        colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
    }
    
    private var logoView: some View {
        Circle()
            .fill(colorScheme == .dark ? Color.red : Color.blue)
            .frame(width: logoSize, height: logoSize)
            .overlay(
                Text("PY")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.title)
            )
    }
    
    private var welcomeText: some View {
        Text("Добро пожаловать в PyOn!")
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .font(.title)
    }
    
    private var loginText: some View {
        Text("Для продолжения необходимо авторизоваться.")
            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            .font(.subheadline)
    }
    
    private var loginFields: some View {
        Group {
            TextField("Логин", text: $viewModel.login)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            viewModel.loginToServer() // Попытка входа
        }) {
            Text("Войти")
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .frame(width: buttonWidth, height: buttonHeight)
                .background(Color.blue)
                .cornerRadius(15)
        }
    }
    
    private var errorMessageView: some View {
        Text(viewModel.loginMessage) // Отображение сообщения об ошибке
            .foregroundColor(.red)
            .padding(.horizontal)
    }
    
    private var registrationButton: some View {
        Button("Создать новый аккаунт") {
            shouldShowRegistration = true // Переход к RegistrationView
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .padding()
        .frame(width: buttonWidth, height: buttonHeight)
        .background(Color.blue)
        .cornerRadius(15.0)
    }
    
    private var loadingIndicator: some View {
        ProgressView() // Загрузочный индикатор
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(3)
    }
}

class LoginViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var loginMessage: String = ""
    @Published var isLoginActive: Bool = false
    @Published var isLoggedIn: Bool = false
    
    func loginToServer() {
        guard let serverURL = URL(string: "\(ServerConfig.serverIP)/api/login") else {
            loginMessage = "Ошибка: неверный URL"
            return
        }
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = [
            "login": login,
            "password": password
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            loginMessage = "Ошибка: неверный формат данных"
            return
        }
        
        request.httpBody = httpBody
        
        isLoginActive = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoginActive = false
                
                if let error = error {
                    self.loginMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.loginMessage = "Ошибка: Невозможно получить о123твет"
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    self.isLoggedIn = true // Успешный вход
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // Закрытие клавиатуры

                case 401:
                    self.loginMessage = "Ошибка: Неверные учетные данные" // Ошибка при неверных данных
                default:
                    self.loginMessage = "Ошибка: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: FirstView {
        FirstView()
    }
}
