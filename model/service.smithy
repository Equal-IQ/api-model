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
    NylasResource
    MeetingBotResource
  ]
  operations: [
    GetProfile
    UpdateProfile
    UploadProfilePicture
    GetProfilePicture

    // audit.smithy - GetAuditStatistics is cross-cutting (aggregates all logs, not bound to single log)
    GetAuditStatistics

    // nylas.smithy - Cross-cutting Nylas operations (resource-bound operations are on NylasResource)
    NylasInitiateAuth
    NylasListConnections
    NylasGetThread

    // Utility operations
    Ping
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