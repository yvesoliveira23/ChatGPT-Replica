import RxBlocking

import RxSwift

import RxTest

import XCTest

@testable import ChatGPTReplica

class ChatServiceRxTests: XCTestCase {

    var chatService: ChatService!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        chatService = ChatService()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        chatService = nil
        disposeBag = nil
        super.tearDown()
    }

    func testMessagesObservable_WithUpdatedMessages_ShouldEmitLatestMessages() {
        // Given
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver([ChatMessage].self)

        chatService.messagesObservable
            .subscribe(observer)
            .disposed(by: disposeBag)

        // When
        let testMessage = ChatMessage(sender: "Test", content: "Test message")
        let testResponse = ChatMessage(sender: "Bot", content: "Test response")

        // Use private API to update messages (for testing only)
        let mirror = Mirror(reflecting: chatService)
        if let _messages = mirror.children.first(where: { $0.label == "_messages" })?.value
            as? BehaviorRelay<[ChatMessage]>
        {
            _messages.accept([testMessage, testResponse])
        }

        // Then
        XCTAssertEqual(observer.events.count, 1)
        if let messages = observer.events.first?.value.element {
            XCTAssertEqual(messages.count, 2)
            XCTAssertEqual(messages[0].content, "Test message")
            XCTAssertEqual(messages[1].content, "Test response")
        } else {
            XCTFail("No messages observed")
        }
    }

    func testErrorObservable_WithErrorMessage_ShouldEmitErrorString() {
        // Given
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)

        chatService.errorObservable
            .subscribe(observer)
            .disposed(by: disposeBag)

        // When
        let testError = "Test error"

        // Use private API to emit error (for testing only)
        let mirror = Mirror(reflecting: chatService)
        if let _error = mirror.children.first(where: { $0.label == "_error" })?.value
            as? PublishSubject<String>
        {
            _error.onNext(testError)
        }

        // Then
        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events.first?.value.element, "Test error")
    }

    func testSendMessage_WithValidMessage_ShouldReturnResponseObservable() {
        // Given
        let testMessage = ChatMessage(sender: "User", content: "Hello, test")
        let expectation = XCTestExpectation(
            description: "Message should be sent and response received")

        // When
        let responseObservable = chatService.sendMessage(testMessage)

        // Then
        responseObservable
            .subscribe(
                onNext: { response in
                    XCTAssertEqual(response.sender, "Bot")
                    XCTAssertFalse(response.content.isEmpty)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail("Should not fail with error: \(error)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testSendMessage_WithCachedMessage_ShouldReturnCachedResponse() {
        // Given
        let testMessage = ChatMessage(sender: "User", content: "Cached message test")
        let cachedResponse = "This is a cached response"

        // Manually add to cache using mirror
        if let mirror = Mirror(reflecting: chatService).children.first(where: {
            $0.label == "cache"
        })?.value as? NSCache<NSString, NSData>,
            let data = cachedResponse.data(using: .utf8)
        {
            mirror.setObject(data as NSData, forKey: testMessage.content as NSString)
        }

        // When
        let expectation = XCTestExpectation(description: "Cached response should be returned")

        // Then
        chatService.sendMessage(testMessage)
            .subscribe(onNext: { response in
                XCTAssertEqual(response.sender, "Bot")
                XCTAssertEqual(response.content, cachedResponse)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 2.0)
    }
}
