//  ProfileView.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI

struct ProfileView: View {
    @State private var shouldLogout = false
    @Environment(\.colorScheme) var colorScheme
    @State private var profile: ProfileData?
    @State private var profileImage: Image?
    let userLogin: String

    init(login: String) {
        self.userLogin = login
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            profileImageView
                .padding(.top, 44)
                .frame(maxWidth: .infinity)

            profileInfo
                .padding(.leading, 20)

            Spacer()

            logoutButton
                .padding(.bottom, 20)
        }
        .onAppear {
            loadProfile()
        }
        .fullScreenCover(isPresented: $shouldLogout) {
            FirstView() // Переход к FirstView при нажатии кнопки "Выйти из аккаунта"
        }
    }

    private var profileImageView: some View {
        HStack {
            Spacer()
            (profileImage ?? Image(systemName: "person.circle.fill"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(colorScheme == .dark ? .white : .black, lineWidth: 4)
                )
            Spacer()
        }
    }

    private var profileInfo: some View {
        Group {
            Text("Имя: \(profile?.firstName ?? "Нет данных")")
            Text("Фамилия: \(profile?.lastName ?? "Нет данных")")
            Text("Школа: \(profile?.school ?? "Нет данных")")
            Text("Класс: \(profile?.grade ?? "Нет данных")")
        }
        .font(.title2)
        .foregroundColor(colorScheme == .dark ? .white : .black)
    }

    private var logoutButton: some View {
        Button("Выйти из аккаунта", action: logout)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.blue)
            .cornerRadius(15.0)
    }

    private func logout() {
        shouldLogout = true
    }

    private func loadProfile() {
        let profileDataURL = "http://127.0.0.1:80/api/profile/\(userLogin)"
        let profileImageURL = "http://127.0.0.1:80/api/uploads/\(userLogin)"
        
        fetchData(from: profileDataURL) { data in
            if let data = data {
                do {
                    let profileData = try JSONDecoder().decode(ProfileData.self, from: data)
                    DispatchQueue.main.async {
                        self.profile = profileData
                    }
                } catch {
                    print("Ошибка декодирования данных профиля: \(error)")
                }
            } else {
                print("Ошибка загрузки данных профиля")
            }
        }

        fetchData(from: profileImageURL) { data in
            if let data, let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            } else {
                print("Ошибка загрузки изображения профиля")
            }
        }
    }

    private func fetchData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }
}

struct ProfileData: Decodable {
    let firstName: String?
    let lastName: String?
    let school: String?
    let grade: String?
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: ProfileView {
        ProfileView(login: "Test")
    }
}
