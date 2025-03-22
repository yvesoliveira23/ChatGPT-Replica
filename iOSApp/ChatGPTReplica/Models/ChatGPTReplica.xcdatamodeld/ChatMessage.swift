import CoreData

@objc(ChatMessageEntity)
public class ChatMessageEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var sender: String
    @NSManaged public var timestamp: Date
}