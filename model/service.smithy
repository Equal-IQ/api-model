$version: "2"

namespace equaliq

use aws.protocols#restJson1

/// Equal IQ API Service
/// Provides contract management, upload, sharing, and user profile functionality
@restJson1
service EqualIQ {
  version: "2023-01-01"
  resources: [
    // Organization resources
    Organization

    // User profile resources
    User
  ]
  operations: [
    // contracts.smithy
    GetContract
    ListContracts
    GetSpecialContract
    ListSpecialContracts
    GetUploadURL
    UpdateContract
    DeleteContract
    ShareContract
    GetContractReadURL

    // users.smithy - GetProfile is standalone (not resource-bound) to support optional userId
    GetProfile

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