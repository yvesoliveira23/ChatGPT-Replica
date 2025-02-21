import XCTest
@testable import ChatGPTReplica

// MARK: - ChatViewControllerTests Class
class ChatViewControllerTests: XCTestCase {

    // MARK: - Properties
    var chatViewController: ChatViewController!
    var mockChatService: MockChatService!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockChatService = MockChatService()
        chatViewController = ChatViewController()
        chatViewController.chatService = mockChatService
        chatViewController.loadViewIfNeeded()
    }

    override func tearDown() {
        chatViewController = nil
        mockChatService = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testSendMessage_WithValidMessage_ShouldAddMessageToView() {
        // Given
        let message = "Hello, ChatGPT!"
        mockChatService.mockResponse = "Response from ChatGPT"
        
        // When
        chatViewController.sendMessage(message)
        
        // Then
        XCTAssertEqual(chatViewController.chatView?.messages.last?.content, "Response from ChatGPT")
    }

    func testSendMessage_WithError_ShouldShowAlert() {
        // Given
        let message = "Hello, ChatGPT!"
        mockChatService.mockError = NSError(domain: "ChatService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        
        // When
        chatViewController.sendMessage(message)
        
        // Then
        XCTAssertTrue(chatViewController.showAlert)
        XCTAssertEqual(chatViewController.alertMessage, "Test Error")
    }
}

// MARK: - MockChatService Class
class MockChatService: ChatService {
    var mockResponse: String?
    var mockError: Error?

    override func sendMessage(message: String, completion: @escaping (String?, Error?) -> Void) {
        if let error = mockError {
            completion(nil, error)
        } else {
            completion(mockResponse, nil)
        }
    }
}