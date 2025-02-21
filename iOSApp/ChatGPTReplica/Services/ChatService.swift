import Foundation

// MARK: - ChatService Class
class ChatService {

    // MARK: - Properties
    private let baseURL =
        ProcessInfo.processInfo.environment["BACKEND_URL"] ?? "http://localhost:3000/api"
    private let apiKey = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"] ?? "default_key"

    // MARK: - Methods
    func sendMessage(message: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/sendMessage") else {
            completion(
                nil,
                NSError(
                    domain: "ChatService", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(
                    nil,
                    NSError(
                        domain: "ChatService", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [])
                    as? [String: Any],
                    let responseMessage = json["response"] as? String
                {
                    completion(responseMessage, nil)
                } else {
                    completion(
                        nil,
                        NSError(
                            domain: "ChatService", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
                }
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }
}
