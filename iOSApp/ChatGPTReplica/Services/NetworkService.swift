import Foundation

import RxSwift

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(Int)
    case invalidData
    case serverError(String)
    case decodingError(Error)
}
class NetworkService {

    static let shared = NetworkService()
    private init() {}

    func request<T: Decodable>(
        endpoint: String, method: String = "GET", parameters: [String: Any]? = nil
    ) -> Observable<T> {
        return Observable.create { observer in
            guard var urlComponents = URLComponents(string: "https://api.openai.com/v1/" + endpoint)
            else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }

            // Configure request
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // Add API key from environment
            if let apiKey = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"] {
                request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            } else {
                // Log missing API key but don't fail - might be injected at runtime
                print("Warning: CHATGPT_API_KEY environment variable not found")
            }

            // Add body parameters for non-GET requests
            if let parameters = parameters, method != "GET" {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    observer.onError(error)
                    return Disposables.create()
                }
            }

            // Create and start URLSession task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.invalidResponse(-1))
                    return
                }

                // Check for successful status code
                guard 200..<300 ~= httpResponse.statusCode else {
                    observer.onError(NetworkError.invalidResponse(httpResponse.statusCode))
                    return
                }

                guard let data = data else {
                    observer.onError(NetworkError.invalidData)
                    return
                }

                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(decodedObject)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError(error))
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
