import SwiftUI
import ViewInspector

// MARK: - ChatView
struct ChatView: View {

    // MARK: - Properties
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

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
                message: Text(alertMessage)
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityLabel("Error alert: \(alertMessage)")
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
        .onChange(of: messages) { _ in
            UIAccessibility.post(notification: .announcement, argument: "New message received")
        }
    }

    // MARK: - Subviews
    private var messageList: some View {
        List(messages) { message in
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
        messages.append(newMessage)
        userInput = ""
        do {
            try ChatService.sendMessage(newMessage)
        } catch {
            alertMessage = "Failed to send message: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

extension ChatView: Inspectable {}
