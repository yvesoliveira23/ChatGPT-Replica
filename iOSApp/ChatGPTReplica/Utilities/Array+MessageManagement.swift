import Foundation

extension Array where Element == ChatMessage {
    mutating func limitMessages(to limit: Int) {
        if count > limit {
            removeFirst(count - limit)
        }
    }
}