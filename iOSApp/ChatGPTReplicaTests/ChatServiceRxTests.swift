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

    func testMessagesObservable() {
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

    func testErrorObservable() {
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
}
