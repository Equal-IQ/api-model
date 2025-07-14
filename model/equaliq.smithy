$version: "2"

namespace equaliq

use aws.protocols#restJson1

/// Equal IQ API Service
/// Provides contract management, upload, sharing, and user profile functionality
@restJson1
service EqualIQ {
    version: "2023-01-01"
    operations: [
        // contracts.smithy
        GetContract
        ListContracts
        GetContractAnalysis
        GetContractMetadata
        ListContractMetadata
        GetSpecialContract
        ListSpecialContracts
        GetTTSURLs
        GetUploadURL
        UpdateContract
        DeleteContract
        ShareContract
        GetContractReadURL

        // profiles.smithy
        GetProfile
        GetProfilePicture
        UploadProfilePicture
        UpdateProfile

        // Utility operations
        Ping
        ExposeTypes
    ]

}

// When changing APIs, we sometimes want to expose unified types that aren't directly tied to any API.
structure ExposedTypes { 
  QASectionsList: QASectionsList // This type is not properly included in API response currently
  ContractVariable: ContractVariable // New feature in development by Ty
  ContractVariableType: ContractVariableType // New feature in development by Ty
}

// This API is used simply to expose types
@http(method: "POST", uri: "/notARealEndpoint")
operation ExposeTypes {
  output: ExposedTypes
}

// Utility operations
@http(method: "POST", uri: "/ping")
operation Ping {
    input: PingInput
    output: PingOutput
}

structure PingInput {
    // Empty input - no authentication required
}

structure PingOutput {
    @required
    message: String
}

// Error structures
@error("client")
structure AuthenticationError {
    @required
    message: String
}

@error("client")
structure ResourceNotFoundError {
    @required
    message: String
}

@error("client")
structure ValidationError {
    @required
    message: String
}

@error("client")
structure ProcessingIncompleteError {
    @required
    message: String
}

@error("server")
structure InternalServerError {
    @required
    message: String
}
