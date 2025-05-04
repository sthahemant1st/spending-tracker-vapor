//
//  LoginRequest.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Vapor

struct LoginRequest: Content {
    var username: String
    var password: String
}
