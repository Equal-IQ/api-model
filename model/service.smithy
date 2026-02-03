$version: "2"

namespace equaliq

use aws.protocols#restJson1

/// Equal IQ API Service
/// Provides contract management, upload, sharing, and user profile functionality
@restJson1
service EqualIQ {
  version: "2023-01-01"
  resources: [
    Organization
    User
    Contract // -- DEPRECATED
    DealResource
    FileResource
    AuditLogResource
  ]
  operations: [
    // contracts.smithy
    ListSpecialContracts
    GetUploadURL
    

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

// This API is used simply to expose types
@http(method: "POST", uri: "/notARealEndpoint")
operation ExposeTypes {
    output := {
        contractAnalysisRecord: ContractAnalysisRecord
    }
}

@http(method: "POST", uri: "/ping")
operation Ping {
    input := {}

    output := {
        @required
        message: String
    }
}