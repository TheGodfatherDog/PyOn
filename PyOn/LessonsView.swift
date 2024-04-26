//
//  LessonsView.swift
//  PyOn
//
//  Created by Андрей Храмцов on 18.04.2024.
//
import SwiftUI
import WebKit

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
    @State private var showModal: Bool = false
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
                                selectedLesson = lesson
                                showModal = true
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
        .onAppear(perform: loadLessons)
        .sheet(isPresented: $showModal) {
            if let lesson = selectedLesson {
                LessonContentView(lessonUrl: lesson.url)
            }
        }
    }

    private func loadLessons() {
        guard let url = URL(string: "\(ServerConfig.serverIP)/api/lessons/\(login)") else {
            isLoading = false
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    lessons = try JSONDecoder().decode([Lesson].self, from: data)
                }
            }
            isLoading = false
        }
    }

    private func toggleFavorite(for lesson: Lesson) {
        if let index = lessons.firstIndex(where: { $0.id == lesson.id }) {
            lessons[index].done.toggle()

            guard let url = URL(string: "\(ServerConfig.serverIP)/api/update_favorite/\(login)") else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            if let data = try? JSONSerialization.data(withJSONObject: ["lesson_id": lesson.id], options: []) {
                URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
            }
        }
    }
}

struct LessonContentView: View {
    var lessonUrl: String
    @State private var lessonContent: String = ""
    @State private var isLoading: Bool = true
    @State private var error: String? = nil

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Загрузка содержимого урока...")
            } else if let error = error {
                Text("Ошибка: \(error)")
            } else {
                WebView(htmlString: lessonContent)
            }
        }
        .onAppear(perform: loadLessonContent)
    }

    private func loadLessonContent() {
        guard let url = URL(string: "\(ServerConfig.serverIP)\(lessonUrl)") else {
            isLoading = false
            error = "Неверный URL"
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let content = String(data: data, encoding: .utf8) {
                        lessonContent = content
                    } else {
                        error = "Ошибка в содержимом"
                    }
                } else {
                    error = "Ошибка сервера"
                }
            }
            isLoading = false
        }
    }
}

struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if htmlString.starts(with: "http"), let url = URL(string: htmlString) {
            uiView.load(URLRequest(url: url))
        } else {
            uiView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(login: "Test")
    }
}
