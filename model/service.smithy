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
  ]
  operations: [
    GetProfile
    UpdateProfile
    UploadProfilePicture
    GetProfilePicture

    // audit.smithy - GetAuditStatistics is cross-cutting (aggregates all logs, not bound to single log)
    GetAuditStatistics

    // nylas.smithy - Email integration operations
    NylasListMessages
    NylasGetMessage
    NylasSendMessage
    NylasInitiateAuth
    NylasHandleAuthCallback
    NylasGetConnectionStatus
    NylasDisconnectConnection

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