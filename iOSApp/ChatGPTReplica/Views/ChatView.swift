import RxSwift
import SwiftUI
import ViewInspector

// MARK: - ChatView
struct ChatView: View {

    // MARK: - Properties
    @StateObject private var viewModel = ChatViewModel()
    @State private var userInput: String = ""
    @State private var showAlert: Bool = false
    private let disposeBag = DisposeBag()

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Set up bindings when view is created
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { errorMessage in
                self.showAlert = true
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Body
    var body: some View {
        VStack {
            messageList
            inputField
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error")
                    .accessibilityAddTraits(.isHeader),
                message: Text(viewModel.errorMessage ?? "")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel("Error alert: \(viewModel.errorMessage ?? "")")
                    .accessibilityHint("Error message"),
                dismissButton: .default(
                    Text("OK")
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Ok button")
                        .accessibilityHint("Dismisses the error message"))
            )
        }
        .navigationTitle("Chat")
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Chat conversation")
        .accessibilityHint("Contains message history and input field")
        .accessibilityAddTraits([.isDialog, .updatesFrequently])
        .onAppear {
            // Set up additional bindings that require the view to be loaded
            viewModel.messagesObservable
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { messages in
                    if let latestMessage = messages.last {
                        let announcement =
                            "New message from \(latestMessage.sender): \(latestMessage.content)"
                        UIAccessibility.post(notification: .announcement, argument: announcement)
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Subviews
    private var messageList: some View {
        List(viewModel.messages) { message in
            MessageRow(message: message)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .accessibilityLabel("Message from \(message.sender): \(message.content)")
                .accessibilityIdentifier("messageRow")
        }
        .listStyle(.plain)
        .id(UUID())
    }

    private var inputField: some View {
        HStack {
            TextField("Type your message...", text: $userInput, onCommit: sendMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .accessibilityIdentifier("userInput")
                .accessibilityLabel("Message input field")
                .accessibilityHint("Type your message here")

            Button(action: sendMessage) {
                Text("Send")
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .accessibilityLabel("Send button")
                    .accessibilityHint("Tap to send the message")
            }
            .padding(.trailing)
            .accessibilityIdentifier("sendButton")
        }
        .padding()
    }

    // MARK: - Methods
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        viewModel.sendMessage(userInput)
        userInput = ""
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

extension ChatView: Inspectable {}
