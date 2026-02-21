import Foundation
import Contacts
import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.parallax.app", category: "ContactStore")

@MainActor
public class ContactStore: ObservableObject {
    public static let shared = ContactStore()
    
    @Published public var contacts: [String: CNContact] = [:]
    
    private let store = CNContactStore()
    
    private init() {
        requestAccess()
    }
    
    public func requestAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            fetchContacts()
        case .notDetermined:
            store.requestAccess(for: .contacts) { [weak self] granted, error in
                if granted {
                    Task { @MainActor in
                        self?.fetchContacts()
                    }
                } else if let error = error {
                    logger.error("Failed to request contact access: \(error.localizedDescription)")
                }
            }
        case .denied, .restricted:
            logger.warning("Contact access is denied or restricted.")
        @unknown default:
            break
        }
    }
    
    private func fetchContacts() {
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        Task.detached {
            var newMap: [String: CNContact] = [:]
            do {
                try self.store.enumerateContacts(with: request) { contact, _ in
                    // Index by normalized phone numbers
                    for phoneNumber in contact.phoneNumbers {
                        let num = phoneNumber.value.stringValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                        if !num.isEmpty {
                            newMap[num] = contact
                        }
                    }
                    // Index by emails
                    for email in contact.emailAddresses {
                        let emailStr = email.value as String
                        if !emailStr.isEmpty {
                            newMap[emailStr.lowercased()] = contact
                        }
                    }
                }
                
                await MainActor.run {
                    self.contacts = newMap
                }
            } catch {
                logger.error("Error fetching contacts: \(error.localizedDescription)")
            }
        }
    }
    
    /// Resolves a CNContact based on a raw handle (phone number or email).
    public func contact(for handle: String) -> CNContact? {
        // Try strict email match first
        if handle.contains("@"), let c = contacts[handle.lowercased()] {
            return c
        }
        
        // Try normalized digit match
        let digitsOnly = handle.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if !digitsOnly.isEmpty {
            if let c = contacts[digitsOnly] { return c }
            
            // Fallback: Suffix matching (e.g. matching last 10 digits to handle country code mismatches)
            if digitsOnly.count >= 10 {
                let suffix = String(digitsOnly.suffix(10))
                for (key, c) in contacts {
                    if key.hasSuffix(suffix) {
                        return c
                    }
                }
            }
        }
        
        return nil
    }
}
