$version: "2"

namespace equaliq

use aws.protocols#restJson1

/// Equal IQ API Service
/// Provides deal management, upload, sharing, and user profile functionality
@restJson1
service EqualIQ {
  version: "2023-01-01"
  resources: [
    Organization
    User
    DealResource
    FileResource
    AuditLogResource
  ]
  operations: [
    // users.smithy - GetProfile is standalone (not resource-bound) to support optional userId
    GetProfile

    // audit.smithy - GetAuditStatistics is cross-cutting (aggregates all logs, not bound to single log)
    GetAuditStatistics

    // Utility operations
    Ping
    ExposeTypes
  ]
}

// Utility operations

@http(method: "POST", uri: "/ping")
operation Ping {
    input := {}

    output := {
        @required
        message: String
    }
}

// This API is used simply to expose types
@http(method: "POST", uri: "/notARealEndpoint")
operation ExposeTypes {
    output := {
    }
}