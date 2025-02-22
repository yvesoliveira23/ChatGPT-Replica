import SwiftUI
import ViewInspector

// MARK: - ChatView
struct ChatView: View {

    // MARK: - Properties
    @StateObject private var chatService = ChatService()
    @State private var userInput: String = ""
    @State private var showAlert: Bool = false

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
                message: Text(chatService.errorMessage ?? "")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel("Error alert: \(chatService.errorMessage ?? "")")
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
        .onChange(of: chatService.messages) { messages in
            if let latestMessage = messages.last {
            let announcement = "New message from \(latestMessage.sender): \(latestMessage.content)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
            }
        }
        .onChange(of: chatService.errorMessage) { errorMessage in
            guard let error = errorMessage else { return }
            showAlert = true
            UIAccessibility.post(notification: .announcement, argument: "Error occurred: \(error)")
        }
    }

    // MARK: - Subviews
    private var messageList: some View {
        List(chatService.messages) { message in
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
        let newMessage = ChatMessage(sender: "User", content: userInput, timestamp: Date())
        chatService.messages.append(newMessage)
        userInput = ""
        chatService.sendMessage(newMessage)
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

extension ChatView: Inspectable {}
