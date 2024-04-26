//  InterpreterView.swift
//  PyOn
//  Created by Андрей Храмцов on 14.04.2024.

import SwiftUI
import Highlightr

struct PythonEditorView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @Binding var codeText: String
    
    func makeUIView(context: Context) -> UITextView {
        let highlightr = Highlightr()!
        highlightr.setTheme(to: colorScheme == .dark ? "atom-one-dark" : "atom-one-light")
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.attributedText = highlightr.highlight(codeText, as: "python")
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no  // Отключаем автоматическую коррекцию
        textView.spellCheckingType = .no  // Отключаем проверку орфографии
        textView.smartQuotesType = .no  // Отключаем умные кавычки
        textView.smartDashesType = .no  // Отключаем умные тире
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let highlightr = Highlightr()!
        uiView.attributedText = highlightr.highlight(codeText, as: "python")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PythonEditorView
        
        init(_ parent: PythonEditorView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.codeText = textView.text
        }
    }
}

struct InterpreterView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var codeText: String = ""
    @State private var outputText: String = ""

    var body: some View {
        VStack {
            PythonEditorView(codeText: $codeText)
                .frame(minHeight: 200, maxHeight: 500)
                .border(colorScheme == .dark ? Color.white : Color.black, width: 1)
                .padding()
            
            Button("Запустить") {
                runCodeOnServer(codeText)
            }
            .padding()
            
            ScrollView {
                Text(outputText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .border(colorScheme == .dark ? Color.white : Color.black, width: 1)
            .padding()
        }
    }

    func runCodeOnServer(_ code: String) {
        let normalizedCode = code.replacingOccurrences(of: "“", with: "\"")
                                .replacingOccurrences(of: "”", with: "\"")

        guard let url = URL(string: "\(ServerConfig.serverIP)/api/run_code") else {
            outputText = "Ошибка: неверный URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["code": normalizedCode]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    outputText = "Ошибка: \(error.localizedDescription)"
                    return
                }

                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let output = (json as? [String: Any])?["output"] as? String {
                            outputText = output
                        } else if let errorMsg = (json as? [String: Any])?["error"] {
                            outputText = "Ошибка: \(errorMsg)"
                        } else {
                            outputText = "Ошибка: неверный формат ответа сервера"
                        }
                    } catch {
                        outputText = "Ошибка: \(error.localizedDescription)"
                    }
                } else {
                    outputText = "Ошибка: нет данных"
                }
            }
        }.resume()
    }
}

struct PyOnView_Previews: PreviewProvider {
    static var previews: InterpreterView {
        InterpreterView()
    }
}
