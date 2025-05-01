//
//  EmailService.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Foundation
import Vapor

protocol EmailService: Sendable {
    func sendEmailVerificationToken(to email: String, with token: String)
}

private struct EmailServiceKey: StorageKey {
    typealias Value = EmailService
}

extension Application {
    var emailService: (any EmailService)? {
        get {
            self.storage[EmailServiceKey.self]
        } set {
            self.storage[EmailServiceKey.self] = newValue
        }
    }
}

struct TemporaryEmailService: EmailService {
    func sendEmailVerificationToken(to email: String, with token: String) {
        print("Sending email verification token to \(email): \(token)")
    }
}
