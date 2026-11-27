import UserNotifications

// Adds the forecast picture to a powder alert. snowway.app sends its URL as "image" with mutable-content.
// If the download fails or is slow, the alert still arrives as plain text.
class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var content: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        let content = (request.content.mutableCopy() as? UNMutableNotificationContent) ?? UNMutableNotificationContent()
        self.content = content
        guard let raw = request.content.userInfo["image"] as? String, let url = URL(string: raw), url.host == "snowway.app" else {
            return contentHandler(content)
        }
        URLSession.shared.downloadTask(with: url) { file, response, _ in
            defer { contentHandler(content) }
            guard let file, (response as? HTTPURLResponse)?.statusCode == 200 else { return }
            let target = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png")
            guard (try? FileManager.default.moveItem(at: file, to: target)) != nil,
                  let attachment = try? UNNotificationAttachment(identifier: "forecast", url: target) else { return }
            content.attachments = [attachment]
        }.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let content { contentHandler(content) }
    }
}
