import Vapor

enum UserError {
    case usernameToken
}

extension UserError: AbortError {
    var description: String {
        reason
    }

    var status: HTTPResponseStatus {
        switch self {
        case .usernameToken:
            return .conflict
        }
    }

    var reason: String {
        switch self {
        case .usernameToken:
            return "Username already taken"
        }
    }
}