//
//  ProfileResponse.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//

import Vapor

public struct ProfileResponse: Content {
    public var firstName: String
    public var middleName: String?
    public var lastName: String
    public var email: String
    public var username: String
}
