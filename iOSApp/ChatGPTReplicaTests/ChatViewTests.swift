import SwiftUI
import ViewInspector
import XCTest

// MARK: - ChatViewTests Class
@testable import ChatGPTReplica

// MARK: - ViewInspector Extension
class ChatViewTests: XCTestCase {

    // MARK: - Properties
    var chatView: ChatView!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        chatView = ChatView()
    }

    override func tearDown() {
        chatView = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testSendMessage_WithValidMessage_ShouldAddMessageToView() throws {
        // Given
        let message = "Hello, ChatGPT!"
        chatView.userInput = message

        // When
        try chatView.inspect().find(button: "Send").tap()

        // Then
        XCTAssertEqual(chatView.messages.last?.content, message)
    }

    func testSendMessage_WithError_ShouldShowAlert() throws {
        // Given
        let message = "Hello, ChatGPT!"
        chatView.userInput = message

        // Simulate an error in the ChatService
        let mockError = NSError(
            domain: "ChatService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        ChatService.sendMessage = { _ in throw mockError }

        // When
        try chatView.inspect().find(button: "Send").tap()

        // Then
        XCTAssertTrue(chatView.showAlert)
        XCTAssertEqual(chatView.alertMessage, "Failed to send message: Test Error")
    func testMessageRow_WithValidMessage_ShouldDisplayCorrectContent() throws {
        // Given
        let message = ChatMessage(
            sender: "User",
            content: "Test message",
            timestamp: Date()
        )
        
        // When
        let messageRow = MessageRow(message: message)
        
        // Then
        let sender = try messageRow.inspect().find(text: "User").string()
        let content = try messageRow.inspect().find(text: "Test message").string()
        
        XCTAssertEqual(sender, "User")
        XCTAssertEqual(content, "Test message")
    }

    // MARK: - Accessibility Tests
    func testSendButton_WithAccessibility_ShouldHaveCorrectLabelAndTraits() throws {
        // Given
        let sendButton = try chatView.inspect().find(button: "Send")

        // Then
        XCTAssertEqual(try sendButton.accessibilityLabel(), "Send")
        XCTAssertEqual(try sendButton.accessibilityTraits(), .button)
    }

    func testMessageTextField_WithAccessibility_ShouldHaveCorrectLabelAndTraits() throws {
        // Given
        let textField = try chatView.inspect().find(textField: "Message")

        // Then
        XCTAssertEqual(try textField.accessibilityLabel(), "Message Input")
        XCTAssertEqual(try textField.accessibilityTraits(), .none)
    }
}

extension ChatView: Inspectable {}
