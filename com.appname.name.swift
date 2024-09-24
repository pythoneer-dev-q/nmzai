import SwiftUI
import SwiftSoup

struct ContentView: View {
    @State private var userInput: String = ""  // Поле для ввода ника пользователя
    @State private var username: String = ""
    @State private var description: String = ""
    @State private var statusMessage: String = ""

    var body: some View {
        VStack {
            Text("Введите Telegram ник:")
            TextField("Введите ник...", text: $userInput)  // Поле для ввода
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                self.fetchTelegramData(nickname: self.userInput)
            }) {
                Text("Отправить запрос")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .foregroundColor(.red)
            } else {
                if !username.isEmpty {
                    Text("Имя в системе: \(username)")
                }
                if !description.isEmpty {
                    Text("BIO: \(description)")
                }
                if !userInput.isEmpty {
                    Text("Прямая ссылка на диалог: t.me/\(userInput)\nBY @PYTHON_ENTER (TELEGRAM)")
                }
            }
        }
        .padding()
    }

    func fetchTelegramData(nickname: String) {
        let url = URL(string: "https://t.me/\(nickname)")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.statusMessage = "Не удалось подключиться к Telegram"
                }
                return
            }

            do {
                let html = String(data: data, encoding: .utf8)
                let document = try SwiftSoup.parse(html!)

                let userNameTag = try document.select("meta[property=og:title]").first()
                let userDescriptionTag = try document.select("meta[property=og:description]").first()

                DispatchQueue.main.async {
                    if let userNameTag = userNameTag {
                        self.username = try! userNameTag.attr("content")
                    } else {
                        self.statusMessage = "Такого username не существует"
                    }

                    if let userDescriptionTag = userDescriptionTag {
                        self.description = try! userDescriptionTag.attr("content")
                    }

                    if self.username.isEmpty {
                        self.statusMessage = "Такого username не существует"
                    } else {
                        self.statusMessage = ""
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "Ошибка при разборе страницы"
                }
            }
        }

        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}