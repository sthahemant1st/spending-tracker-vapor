//
//  LoginDTO.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Vapor

struct LoginDTO: Content {
    var username: String
    var password: String
}
