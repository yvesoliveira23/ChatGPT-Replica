import SwiftUI

// MARK: - MessageRow View
struct MessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            Text(message.sender)
                .fontWeight(.bold)
                .accessibilityLabel("Sender: \(message.sender)")
            Text(message.content)
                .accessibilityLabel("Message: \(message.content)")
            Spacer()
            Text(message.timestamp, style: .time)
                .accessibilityLabel("Timestamp: \(message.timestamp)")
        }
        .padding()
        .accessibilityLabel("Message row")
    }
}