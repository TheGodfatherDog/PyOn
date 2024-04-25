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
            } else {
                Text("Ошибка: выбранный урок не найден.")
            }
        }
    }

    private func loadLessons() {
        guard let url = URL(string: "http://127.0.0.1:80/api/lessons/\(login)") else {
            isLoading = false
            print("Ошибка: неверный URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Ошибка при загрузке уроков: \(error.localizedDescription)")
                    return
                }

                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Ошибка: неверный ответ от сервера.")
                    return
                }

                if let data = data {
                    do {
                        lessons = try JSONDecoder().decode([Lesson].self, from: data)
                        print("Уроки успешно загружены.")
                    } catch {
                        print("Ошибка при декодировании данных: \(error.localizedDescription)")
                    }
                } else {
                    print("Нет данных")
                }
            }
        }.resume()
    }

    private func toggleFavorite(for lesson: Lesson) {
        guard let index = lessons.firstIndex(where: { $0.id == lesson.id }) else {
            print("Ошибка: урок с id \(lesson.id) не найден.")
            return
        }

        lessons[index].done.toggle()

        guard let url = URL(string: "http://127.0.0.1:80/api/update_favorite/\(login)") else {
            print("Ошибка: неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["lesson_id": lesson.id], options: [])

        } catch {
            print("Ошибка при подготовке данных: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Ошибка при обновлении избранного: \(error.localizedDescription)")
            }
        }.resume()
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
                Text("Загрузка содержимого урока...")
            } else if let error = error {
                Text("Ошибка: \(error)")
            } else {
                WebView(htmlString: lessonContent)
            }
        }
        .onAppear(perform: loadLessonContent)
    }

    private func loadLessonContent() {
        guard let url = URL(string: "http://127.0.0.1:80\(lessonUrl)") else {
            isLoading = false
            error = "Неверный URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {


                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    isLoading = false
                    return
                }

                if let data = data {
                    if let content = String(data: data, encoding: .utf8) {
                        lessonContent = content
                        isLoading = false
                    } else {
                        isLoading = false
                    }
                } else {
                    isLoading = false
                }
            }
        }.resume()
    }
}



struct WebView: UIViewRepresentable {
    let htmlString: String
    var navigationDelegate: WKNavigationDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if htmlString.starts(with: "http") {
            if let url = URL(string: htmlString) {
                uiView.load(URLRequest(url: url))
            } else {
                print("Ошибка: неверный URL")
            }
        } else {
            uiView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("WebView: загрузка началась.")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView: загрузка завершена.")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView: ошибка загрузки - \(error.localizedDescription).")
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: LessonsView {
        LessonsView(login: "Test")
    }
}
