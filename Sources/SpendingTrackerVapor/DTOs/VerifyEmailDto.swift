//
//  VerifyEmailDto.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Vapor

struct VerifyEmailDto: Content {
    var token: String
}
