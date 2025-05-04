//
//  RefreshTokenRequest.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//

import Vapor

struct RefreshTokenRequest: Content {
    let refreshToken: String
}
