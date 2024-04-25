////
////  LoginView.swift
////  PyOn
////
////  Created by Андрей Храмцов on 14.04.2024.
////
//
//import SwiftUI
//import Combine
//
//class LoginViewModel: ObservableObject {
//    @Published var login: String = ""
//    @Published var password: String = ""
//    @Published var loginMessage: String = ""
//    @Published var isLoginActive: Bool = false
//    @Published var isLoggedIn: Bool = false // Добавляем новое состояние для отслеживания успешного входа
//    
//    func loginToServer() {
//        guard let ServerURL = URL(string: "http://127.0.0.1:80/api/login") else {
//            print("Ошибка: неверный урл")
//            return
//        }
//        
//        var request = URLRequest(url: ServerURL)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let data: [String: Any] = [
//            "login": login,
//            "password": password
//        ]
//        do {
//            let httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
//            request.httpBody = httpBody
//            print("HTTP body set successfully")
//        } catch {
//            print("Http body error")
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoginActive = false
//                if let error = error {
//                    self.loginMessage = "Ошибка: \(error.localizedDescription)"
//                    return
//                }
//                print("no error in request")
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    self.loginMessage = "Ошибка: Неверный ответ сервера"
//                    return
//                }
//                print("http response есть")
//                switch httpResponse.statusCode {
//                case 200:
//                    print("Успешный вход")
//                    self.isLoggedIn = true // Устанавливаем флаг успешного входа
//                case 401:
//                    print("Ошибка: неверные данные строка 109")
//                default:
//                    print("Ошибка: \(httpResponse.statusCode)")
//                }
//            }
//        }
//        
//        isLoginActive = true
//        print("login started")
//        task.resume()
//    }
//}
//
//
//struct LoginScreenView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var viewModel = LoginViewModel()
//    
//    var body: some View {
//        ZStack {
//            // Используйте переменную colorScheme для определения цвета фона в зависимости от текущей темы
//            Color(colorScheme == .dark ? .black : .white).edgesIgnoringSafeArea(.all)
//            VStack {
//                Text("Войдите в аккаунт")
//                    .font(.largeTitle)
//                    .foregroundColor(colorScheme == .dark ? .white : .black) // Изменение цвета текста в зависимости от темы
//                    .padding([.top, .bottom], 20)
//                
//                TextField("Логин", text: $viewModel.login)
//                    .autocapitalization(.none)
//                    .padding()
//                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)) // Изменение цвета фона текстового поля в зависимости от темы
//                    .cornerRadius(5.0)
//                    .padding(.bottom, 20)
//                    .foregroundColor(colorScheme == .dark ? .white : .black) // Изменение цвета текста в зависимости от темы
//                
//                SecureField("Пароль", text: $viewModel.password)
//                    .padding()
//                    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)) // Изменение цвета фона текстового поля в зависимости от темы
//                    .cornerRadius(5.0)
//                    .padding(.bottom, 20)
//                    .foregroundColor(colorScheme == .dark ? .white : .black) // Изменение цвета текста в зависимости от темы
//                
//                Button("Войти", action: viewModel.loginToServer)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 220, height: 60)
//                    .background(Color.blue)
//                    .cornerRadius(15.0)
//                
//                Text(viewModel.loginMessage)
//                    .foregroundColor(.red)
//                    .padding()
//                
//                HStack {
//                    Text("Забыли пароль?")
//                        .foregroundColor(colorScheme == .dark ? .gray : .white) // Изменение цвета текста в зависимости от темы
//                        .font(.footnote)
//                        .padding(.top, 10)
//                }
//            }
//            .padding()
//            
//            if viewModel.isLoggedIn { // Переходим на ContentView после успешного входа
//                ContentView(login: viewModel.login)
//            }
//        }
//    }
//}
//
//
//struct LoginScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginScreenView()
//    }
//}
