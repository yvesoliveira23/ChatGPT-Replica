import XCTest

// MARK: - ChatServiceTests Class
@testable import ChatGPTReplica

// MARK: - MockURLSession Class

// MARK: - MockURLSessionDataTask Class
class ChatServiceTests: XCTestCase {

    // MARK: - Properties
    var chatService: ChatService!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        chatService = ChatService()
    }

    override func tearDown() {
        chatService = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testSendMessage_WithValidMessage_ShouldReturnResponse() {
        // Given
        let expectation = self.expectation(description: "Valid message should return a response")
        let message = "Hello, ChatGPT!"

        // When
        chatService.sendMessage(message: message) { response, error in
            // Then
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSendMessage_WithInvalidURL_ShouldReturnError() {
        // Given
        let expectation = self.expectation(description: "Invalid URL should return an error")
        let message = "Hello, ChatGPT!"
        chatService = ChatService()
        chatService.baseURL = "invalid_url"

        // When
        chatService.sendMessage(message: message) { response, error in
            // Then
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            XCTAssertEqual((error as NSError?)?.domain, "ChatService")
            XCTAssertEqual((error as NSError?)?.localizedDescription, "Invalid URL")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSendMessage_WithNoDataReceived_ShouldReturnError() {
        // Given
        let expectation = self.expectation(description: "No data received should return an error")
        let message = "Hello, ChatGPT!"
        let mockURLSession = MockURLSession(data: nil, response: nil, error: nil)
        chatService = ChatService(session: mockURLSession)

        // When
        chatService.sendMessage(message: message) { response, error in
            // Then
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            XCTAssertEqual((error as NSError?)?.domain, "ChatService")
            XCTAssertEqual((error as NSError?)?.localizedDescription, "No data received")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
class MockURLSession: URLSession {
    private let mockData: Data?
    private let mockResponse: URLResponse?
    private let mockError: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
    }

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}
class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}
