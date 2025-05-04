//
//  ProblemDetailsResponse.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//
// Problem Details for HTTP APIs
// https://datatracker.ietf.org/doc/html/rfc7807
// Uniform Resource Identifier (URI): Generic Syntax
// https://datatracker.ietf.org/doc/html/rfc3986

import Vapor
import Fluent

struct ProblemDetailsResponse: Content {
    let type: URI
    let title: String
    let status: Int
    let detail: String?
    let instance: String
    let validationErrors: [String: [String]]?
}

struct ProblemDetailsErrorMiddleware: Middleware {
    func respond(
        to request: Vapor.Request,
        chainingTo next: any Vapor.Responder
    ) -> NIOCore.EventLoopFuture<Vapor.Response> {
        next.respond(to: request).flatMapError { error in
            let problemDetails: ProblemDetailsResponse
            
            if let validationError = error as? ValidationsError {
                // 422 Unprocessable Entity
                var fieldErrors = [String: [String]]()
                for failure in validationError.failures {
                    let field = failure.key.stringValue
                    fieldErrors[field, default: []].append(failure.result.failureDescription ?? "Unknown error")
                }
                problemDetails = ProblemDetailsResponse(
                    type: URI(string: "/probs/validation"),
                    title: "Validation failed",
                    status: 422,
                    detail: "One or more fields have errors.",
                    instance: request.url.path,
                    validationErrors: fieldErrors
                )
            } else if let abortError = error as? (any AbortError) {
                // Any other client or auth error
                problemDetails = ProblemDetailsResponse(
                    type: URI(string: "/probs/\(abortError.status.code)"),
                    title: abortError.reason,
                    status: Int(abortError.status.code),
                    detail: nil,
                    instance: request.url.path,
                    validationErrors: nil
                )
            } else {
                // Fallback: 500 Internal Server Error
                problemDetails = ProblemDetailsResponse(
                    type: URI(string: "/probs/internal"),
                    title: "Internal Server Error",
                    status: 500,
                    detail: "An unexpected error occurred.",
                    instance: request.url.path,
                    validationErrors: nil
                )
            }
            
            return problemDetails.encodeResponse(for: request).map { res in
                res.headers.replaceOrAdd(name: .contentType, value: "application/problem+json; charset=utf-8")
                res.status = HTTPResponseStatus(statusCode: problemDetails.status)
                return res
            }
        }
    }
}
