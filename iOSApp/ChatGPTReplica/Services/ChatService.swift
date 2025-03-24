import Dotenv

import Foundation

import RxCocoa

import RxSwift

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
    private let disposeBag = DisposeBag()

    // MARK: - RxSwift Properties
    private let _messages = BehaviorRelay<[ChatMessage]>(value: [])
    private let _error = PublishSubject<String>()

    // MARK: - RxSwift Outputs
    var messagesObservable: Observable<[ChatMessage]> {
        return _messages.asObservable()
    }

    var errorObservable: Observable<String> {
        return _error.asObservable()
    }

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

        // Bind published properties to RxSwift subjects
        _messages
            .subscribe(onNext: { [weak self] messages in
                self?.messages = messages
            })
            .disposed(by: disposeBag)

        _error
            .subscribe(onNext: { [weak self] error in
                self?.errorMessage = error
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Cache Setup
    private func setupCache() {
        cache.countLimit = cacheCountLimit  // Maximum number of cached responses
        cache.totalCostLimit = cacheTotalCostLimit  // 10MB limit
    }

    // MARK: - Message Handling
    func sendMessage(_ message: ChatMessage) -> Observable<ChatMessage> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(
                    NSError(
                        domain: "ChatService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Service not available"]))
                return Disposables.create()
            }

            // Check cache first
            if let cachedResponse = self.cache.object(forKey: message.content as NSString) {
                if let cachedData = cachedResponse as Data?,
                    let cachedString = String(data: cachedData, encoding: .utf8)
                {
                    let botMessage = ChatMessage(
                        sender: "Bot", content: cachedString, timestamp: Date())

                    // Update messages
                    var currentMessages = self._messages.value
                    currentMessages.append(message)
                    currentMessages.append(botMessage)
                    self._messages.accept(currentMessages)

                    observer.onNext(botMessage)
                    observer.onCompleted()
                } else {
                    self._error.onNext("Failed to decode cached response")
                    observer.onError(
                        NSError(
                            domain: "ChatService", code: -2,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Failed to decode cached response"
                            ]))
                }
                return Disposables.create()
            }

            // Create and send the API request
            let request = self.createRequest(with: message.content)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self._error.onNext(error.localizedDescription)
                    observer.onError(error)
                    return
                }

                // Process response and cache it
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    if let responseData = responseString.data(using: .utf8) {
                        self.cache.setObject(
                            responseData as NSData, forKey: message.content as NSString)
                    }

                    let botMessage = ChatMessage(
                        sender: "Bot", content: responseString, timestamp: Date())

                    // Update messages
                    var currentMessages = self._messages.value
                    currentMessages.append(message)
                    currentMessages.append(botMessage)
                    self._messages.accept(currentMessages)

                    observer.onNext(botMessage)
                    observer.onCompleted()
                } else {
                    let error = NSError(
                        domain: "ChatService", code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to process response"])
                    self._error.onNext("Failed to process response")
                    observer.onError(error)
                }
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
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
