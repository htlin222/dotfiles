@preconcurrency import EventKit
import Foundation

@main
struct RemindersCLI {
    static func main() async {
        let args = CommandLine.arguments
        guard args.count >= 2 else {
            printError("Usage: reminders-cli fetch | add <name> <body> <due> <priority>")
            exit(3)
        }

        let store = EKEventStore()

        do {
            let granted = try await store.requestFullAccessToReminders()
            guard granted else {
                printError("Permission denied — grant access in System Settings > Privacy > Reminders")
                exit(1)
            }
        } catch {
            printError("Permission error: \(error.localizedDescription)")
            exit(1)
        }

        let command = args[1]

        switch command {
        case "fetch":
            await fetchReminders(store: store)
        case "add":
            guard args.count >= 6 else {
                printError("Usage: reminders-cli add <name> <body> <due_date> <priority>")
                exit(3)
            }
            addReminder(store: store, name: args[2], body: args[3], due: args[4], priority: args[5])
        default:
            printError("Unknown command: \(command). Use 'fetch' or 'add'.")
            exit(3)
        }
    }

    static func findInboxCalendar(store: EKEventStore) -> EKCalendar? {
        let calendars = store.calendars(for: .reminder)
        return calendars.first { $0.title == "Inbox" }
    }

    static func fetchReminders(store: EKEventStore) async {
        guard let inbox = findInboxCalendar(store: store) else {
            printError("No 'Inbox' list found in Reminders.app")
            exit(2)
        }

        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: [inbox]
        )

        let reminders = await withCheckedContinuation { (continuation: CheckedContinuation<[EKReminder]?, Never>) in
            store.fetchReminders(matching: predicate) { result in
                continuation.resume(returning: result)
            }
        }

        guard let reminders = reminders, !reminders.isEmpty else {
            print("[]")
            return
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone.current

        var jsonArray: [[String: Any]] = []
        for r in reminders {
            var entry: [String: Any] = [
                "name": r.title ?? "",
                "body": r.notes ?? "",
            ]
            if let due = r.dueDateComponents?.date {
                entry["due"] = formatter.string(from: due)
            } else {
                entry["due"] = ""
            }
            jsonArray.append(entry)
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.sortedKeys])
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        } catch {
            printError("JSON serialization error: \(error.localizedDescription)")
            exit(3)
        }
    }

    static func addReminder(store: EKEventStore, name: String, body: String, due: String, priority: String) {
        guard let inbox = findInboxCalendar(store: store) else {
            printError("No 'Inbox' list found in Reminders.app")
            exit(2)
        }

        let reminder = EKReminder(eventStore: store)
        reminder.title = name
        reminder.notes = body
        reminder.calendar = inbox

        if let p = Int(priority) {
            reminder.priority = p
        }

        if !due.isEmpty {
            // Parse "YYYY-MM-DD HH:MM" format
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm"
            df.timeZone = TimeZone.current
            if let date = df.date(from: due) {
                reminder.dueDateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: date
                )
            }
        }

        do {
            try store.save(reminder, commit: true)
            print("OK")
        } catch {
            printError("Failed to save reminder: \(error.localizedDescription)")
            exit(3)
        }
    }

    static func printError(_ message: String) {
        FileHandle.standardError.write(Data((message + "\n").utf8))
    }
}
