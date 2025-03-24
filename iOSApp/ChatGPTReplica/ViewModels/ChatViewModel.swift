import Foundation

import RxCocoa

import RxSwift

class ChatViewModel: ObservableObject {
    // MARK: - Properties
    private let chatService = ChatService()
    private let disposeBag = DisposeBag()

    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - RxSwift Properties
    private let _messageText = BehaviorRelay<String>(value: "")
    private let _sendMessage = PublishSubject<String>()

    // MARK: - RxSwift Outputs
    var messagesObservable: Observable<[ChatMessage]> {
        return chatService.messagesObservable
    }

    var error: Observable<String> {
        return chatService.errorObservable
    }

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Bind messages from service to published property
        chatService.messagesObservable
            .subscribe(onNext: { [weak self] messages in
                self?.messages = messages
            })
            .disposed(by: disposeBag)

        // Bind errors from service to published property
        chatService.errorObservable
            .subscribe(onNext: { [weak self] error in
                self?.errorMessage = error
            })
            .disposed(by: disposeBag)

        // Handle send message
        _sendMessage
            .do(onNext: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMapLatest { [weak self] text -> Observable<ChatMessage> in
                guard let self = self else { return Observable.empty() }
                let message = ChatMessage(sender: "User", content: text, timestamp: Date())
                return self.chatService.sendMessage(message)
            }
            .subscribe(
                onNext: { [weak self] _ in
                    self?.isLoading = false
                },
                onError: { [weak self] error in
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - Public Methods
    func sendMessage(_ text: String) {
        _sendMessage.onNext(text)
    }
}
