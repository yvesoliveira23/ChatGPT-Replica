// MARK: - ChatMessage Model
struct ChatMessage {
    let sender: String
    let content: String
    let timestamp: Date

    // MARK: - Initializer
    init(sender: String, content: String, timestamp: Date = Date()) {
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
    }
}
