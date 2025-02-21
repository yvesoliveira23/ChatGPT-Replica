import Combine
import UIKit
import os.log

class ChatViewController: UIViewController {

    // MARK: - Properties
    private var chatView = ChatView()
    private var chatService: ChatService?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        chatService = ChatService()
        setupBindings()
    }
    // MARK: - Setup Methods
    private func setupView() {
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView)

        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    }

    private func setupBindings() {
        chatView?.sendMessagePublisher
            .sink { [weak self] message in
                self?.sendMessage(message)
            }
            .store(in: &cancellables)
    }

    // MARK: - Helper Methods
    private func sendMessage(_ message: String) {
        guard let chatService = chatService else { return }
        chatService.sendMessage(message: message) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending message: \(error)")
                    self?.chatView?.addMessage(message)
                    self?.chatView?.addMessage(response)
                }
            }
        }
    }
}
