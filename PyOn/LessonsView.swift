//
//  LessonsView.swift
//  PyOn
//
//  Created by Андрей Храмцов on 18.04.2024.
//
import SwiftUI

// Структура урока
struct Lesson: Identifiable, Codable {
    var id: Int
    var title: String
    var done: Bool
    var url: String
}

// Основной вид
struct LessonsView: View {
    var login: String
    @State private var lessons: [Lesson] = []
    @State private var selectedLesson: Lesson?
    @State private var isLoading: Bool = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Загрузка уроков...")
            } else {
                List(lessons) { lesson in
                    HStack {
                        Text(lesson.title)
                            .onTapGesture {
                                if selectedLesson == nil || selectedLesson?.id != lesson.id {
                                    selectedLesson = lesson
                                    showModal.toggle() // Здесь меняем состояние showModal
                                }
                            }
                        Spacer()
                        Button(action: { toggleFavorite(for: lesson) }) {
                            Image(systemName: lesson.done ? "star.fill" : "star")
                                .foregroundColor(lesson.done ? .yellow : .gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadLessons()
            }
        }
        .sheet(isPresented: Binding(
            get: { selectedLesson != nil },
            set: { if !$0 { selectedLesson = nil } } // Закрываем модальное окно
        )) {
            if let lesson = selectedLesson {
                LessonContentView(lessonUrl: lesson.url)
            } else {
                Text("Ошибка: выбранный урок не найден.")
            }
        }
    }
    
    @State private var showModal: Bool = false // Перемещаем эту переменную в конец
    private func loadLessons() async {
        isLoading = true
        do {
            lessons = try await fetchLessons(login: login)
        } catch {
            // Обработка ошибок
        }
        isLoading = false
    }
    
    private func fetchLessons(login: String) async throws -> [Lesson] {
        guard let url = URL(string: "\(ServerConfig.serverIP)/api/lessons/\(login)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Lesson].self, from: data)
    }
    
    private func toggleFavorite(for lesson: Lesson) {
        guard let index = lessons.firstIndex(where: { $0.id == lesson.id }) else {
            return
        }
        
        lessons[index].done.toggle()
        
        Task {
            try await updateFavorite(lessonID: lesson.id, login: login)
        }
    }
    
    private func updateFavorite(lessonID: Int, login: String) async throws {
        guard let url = URL(string: "\(ServerConfig.serverIP)/api/update_favorite/\(login)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try JSONSerialization.data(withJSONObject: ["lesson_id": lessonID], options: [])
        request.httpBody = requestData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}

// Вид для отображения содержимого урока
struct LessonContentView: View {
    var lessonUrl: String
    @State private var lessonContent: String = ""
    @State private var isLoading: Bool = true
    @State private var error: String? = nil
    
    var body: some View {
        VStack {
            if isLoading {
                Text("Загрузка содержимого урока...")
            } else if let error = error {
                Text("Ошибка: \(error)")
            } else {
                WebView(htmlString: lessonContent)
            }
        }
        .onAppear {
            Task {
                await loadLessonContent()
            }
        }
    }
    
    private func loadLessonContent() async {
        guard let url = URL(string: "\(ServerConfig.serverIP)\(lessonUrl)") else {
            isLoading = false
            error = "Неверный URL"
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                isLoading = false
                error = "Неверный ответ сервера"
                return
            }
            
            if let content = String(data: data, encoding: .utf8) {
                lessonContent = content
            } else {
                error = "Ошибка декодирования данных"
            }
        } catch {
        }
        
        isLoading = false
    }
}

// Превью
struct LessonsView_Previews: PreviewProvider {
    static var previews: LessonsView {
        LessonsView(login: "Test")
    }
}
