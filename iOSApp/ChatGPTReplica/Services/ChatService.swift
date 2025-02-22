import Dotenv
import Foundation

class ChatService: ObservableObject {

    // MARK: - Properties
    @Published var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    private let cache = NSCache<NSString, NSData>()
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
    func sendMessage(_ message: ChatMessage) {
        // Check cache first
        if let cachedResponse = cache.object(forKey: message.content as NSString) {
            if let cachedData = cachedResponse as Data?,
                let cachedString = String(data: cachedData, encoding: .utf8)
            {
                DispatchQueue.main.async { [weak self] in
                    self?.messages.append(
                        ChatMessage(sender: "Bot", content: cachedString, timestamp: Date()))
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "Failed to decode cached response"
                }
            }
            return
        }

        // Create and send the API request
        let request = createRequest(with: message.content)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            // Process response and cache it
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                if let responseData = responseString.data(using: .utf8) {
                    self?.cache.setObject(
                        responseData as NSData, forKey: message.content as NSString)
                }
                DispatchQueue.main.async {
                    self?.messages.append(
                        ChatMessage(sender: "Bot", content: responseString, timestamp: Date()))
                }
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to process response"
                }
            }
        }
        task.resume()
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
