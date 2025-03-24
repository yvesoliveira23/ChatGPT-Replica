import Combine
import RxCocoa
import RxSwift
import UIKit
import os.log

class ChatViewController: UIViewController {

    // MARK: - Properties
    private var chatView: UIHostingController<ChatView>?
    private var viewModel: ChatViewModel?
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupView()
        setupBindings()
    }

    // MARK: - Setup Methods
    private func setupViewModel() {
        viewModel = ChatViewModel()
    }

    private func setupView() {
        let chatSwiftUIView = ChatView()
        chatView = UIHostingController(rootView: chatSwiftUIView)

        guard let chatView = chatView else { return }

        addChild(chatView)
        chatView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView.view)

        NSLayoutConstraint.activate([
            chatView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        chatView.didMove(toParent: self)
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }

        // Bind view model error messages to display alerts
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
