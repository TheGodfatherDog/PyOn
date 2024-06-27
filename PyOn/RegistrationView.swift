//
//  RegistrationView.swift
//  PyOn
//
//  Created by Андрей Храмцов on 18.04.2024.
//

import SwiftUI
import Combine

struct RegistrationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var school: String = ""
    @State private var grade: String = ""
    @State private var profileImage: UIImage?
    @State private var showingImagePicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isRegistered: Bool = false // Смена на FirstView после успешной регистрации

    var body: some View {
        NavigationView {
            ZStack {
                Color(colorScheme == .dark ? .black : .white).edgesIgnoringSafeArea(.all)
                VStack {
                    Form {
                        Section(header: Text("Введите необходимую информацию:")) {
                            TextField("Логин", text: $login)
                            SecureField("Пароль", text: $password)
                            TextField("Имя", text: $firstName)
                            TextField("Фамилия", text: $lastName)
                            TextField("Школа", text: $school)
                            TextField("Класс", text: $grade)
                            profileImageRow
                        }
                    }
                    
                    registerButton
                }
                .navigationTitle("Регистрация")
                .sheet(isPresented: $showingImagePicker) {ImagePicker(image: self.$profileImage)}

                if isRegistered {FirstView()}
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Сообщение"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var registerButton: some View {
        Button("Зарегистрироваться", action: registerUser)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.blue)
            .cornerRadius(15.0)
    }
    
    var profileImageRow: some View {
        HStack {
            Text("Фото профиля")
            Spacer()
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            }
            Button(action: {self.showingImagePicker = true}) {Text("Выбрать")}
        }
    }
    
    func registerUser() {
        guard let serverURL = URL(string: "\(ServerConfig.serverIP)/api/register") else {
            alertMessage = "Ошибка: неверный URL"
            showAlert = true
            return
        }
        
        guard let profileImage = profileImage,
              let imageData = profileImage.jpegData(compressionQuality: 1.0),
              !imageData.isEmpty else {
            alertMessage = "Ошибка: изображение не выбрано"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "login": login,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "school": school,
            "grade": grade ]
        
        var body = Data()
        appendParameters(&body, parameters, boundary)
        appendImageData(&body, imageData, boundary)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                alertMessage = "Ошибка: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                alertMessage = "Ошибка: неверный ответ сервера"
                showAlert = true
                return
            }

            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 201:
                    alertMessage = "Успешная регистрация!"
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isRegistered = true
                    }
                case 409:
                    alertMessage = "Ошибка: логин уже существует"
                    showAlert = true
                default:
                    alertMessage = "Ошибка: неизвестная ошибка"
                    showAlert = true
                }
            }
        }
        
        task.resume()
    }
    
    func appendParameters(_ body: inout Data, _ parameters: [String: Any], _ boundary: String) {
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
    }
    
    func appendImageData(_ body: inout Data, _ imageData: Data, _ boundary: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        init(_ parent: ImagePicker) {self.parent = parent}
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage { // Use edited image if available
                parent.image = editedImage.circleMasked // Apply circle masking
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {Coordinator(self)}
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true // Enable editing mode
        picker.sourceType = .photoLibrary // Choose from library
        picker.mediaTypes = ["public.image"] // Images only
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string
            .data(using: .utf8) {
                        append(data)
                    }
                }
            }

            extension UIImage {
                var circleMasked: UIImage? {
                    let imageView = UIImageView(image: self)
                    imageView.contentMode = .scaleAspectFill
                    imageView.frame = CGRect(origin: .zero, size: CGSize(width: min(size.width, size.height), height: min(size.width, size.height)))
                    imageView.layer.cornerRadius = min(size.width, size.height) / 2
                    imageView.layer.masksToBounds = true
                    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
                    guard let context = UIGraphicsGetCurrentContext() else { return nil }
                    imageView.layer.render(in: context)
                    let result = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return result
                }
            }

#Preview("RegView") {RegistrationView()}
