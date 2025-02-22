import Dotenv
import Foundation

// MARK: - ChatService Class
class ChatService {

    // MARK: - Properties
    private let cache = NSCache<NSString, NSString>()
    private let maxMessages = 100
    private let apiKey: String
    private let apiUrl: String
    private let modelName: String
    private let cacheCountLimit: Int
    private let cacheTotalCostLimit: Int

    // MARK: - Initialization
    init(
        modelName: String = "gpt-3.5-turbo", cacheCountLimit: Int = 50,
        cacheTotalCostLimit: Int = 10 * 1024 * 1024
    ) {
        Dotenv.load()
        self.apiKey = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"] ?? ""
        self.modelName = modelName
        self.apiUrl = "https://api.openai.com/v1/chat/completions"
        self.cacheCountLimit = cacheCountLimit
        self.cacheTotalCostLimit = cacheTotalCostLimit
        setupCache()
    }

    // MARK: - Cache Setup
    private func setupCache() {
        cache.countLimit = cacheCountLimit  // Maximum number of cached responses
        cache.totalCostLimit = cacheTotalCostLimit  // 10MB limit
    }

    // MARK: - Message Handling
    public func sendMessage(message: String, completion: @escaping (String?, Error?) -> Void) {
        // Check cache first
        if let cachedResponse = cache.object(forKey: message as NSString) {
            completion(cachedResponse as String, nil)
            return
        }

        // Create and send the API request
        let request = createRequest(with: message)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                completion(nil, error)
                return
            }

            // Process response and cache it
            if let responseString = self.processResponse(data) {
                self.cache.setObject(responseString as NSString, forKey: message as NSString)
                completion(responseString, nil)
            }
        }
        task.resume()
    }

    // MARK: - Helper Methods
    private func processResponse(_ data: Data?) -> String? {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            return nil
        }
        return content
    }

    private func createRequest(with message: String) -> URLRequest {
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "model": modelName, "messages": [["role": "user", "content": message]],
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error: Failed to serialize JSON - \(error.localizedDescription)")
        }
        return request
    }
}
