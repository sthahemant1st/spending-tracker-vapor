//
//  LoginResponse.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//

import Vapor

struct LoginResponse: Content {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}
