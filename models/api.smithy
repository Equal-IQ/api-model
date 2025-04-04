$version: "2"
namespace equaliq

/// Equal IQ API Service
/// Provides contract management, upload, sharing, and user profile functionality
service EqualIQ {
    version: "2023-01-01"
    resources: [
        Contract,
        ContractSummary,
        User
    ]
    operations: [
        Ping
    ]
}

// Resources

// Define two separate resource types while maintaining the same API operation names
resource Contract {
    identifiers: { contractId: ContractId }
    properties: {
        name: String,
        type: ContractType,
        isOwner: Boolean,
        ownerId: UserId,
        sharedWith: UserIdList,
        terms: Document,
        iq_qa: QASections
    }
    read: GetContract
    create: GetUploadURL
    update: UpdateContract
    delete: DeleteContract
    operations: [
        ShareContract,
        GetContractReadURL
    ]
}

resource ContractSummary {
    identifiers: { contractId: ContractId }
    properties: {
        name: String,
        uploadedOn: Timestamp,
        type: ContractType,
        status: ContractStatus,
        isOwner: Boolean,
        ownerId: UserId,
        sharedWith: UserIdList
    }
    list: ListContracts
}

resource User {
    identifiers: { userId: UserId }
    properties: {
        firstName: String,
        lastName: String,
        displayName: String,
        email: String,
        accountType: AccountType,
        bio: String
    }
    read: GetProfile
    update: UpdateProfile
    operations: [
        UploadProfilePicture,
        GetProfilePicture
    ]
}

// Types

@pattern("^[A-Za-z0-9-]+$")
string ContractId

@pattern("^[A-Za-z0-9-]+$")
string UserId

list UserIdList {
    member: UserId
}

@enum([
    {
        value: "processing",
        name: "PROCESSING"
    },
    {
        value: "complete",
        name: "COMPLETE"
    },
    {
        value: "error",
        name: "ERROR"
    },
    {
        value: "awaiting_upload",
        name: "AWAITING_UPLOAD"
    }
])
string ContractStatus

@enum([
    {
        value: "recording",
        name: "RECORDING"
    },
    {
        value: "publishing",
        name: "PUBLISHING"
    },
    {
        value: "management",
        name: "MANAGEMENT"
    },
    {
        value: "producer",
        name: "PRODUCER"
    },
    {
        value: "tbd",
        name: "TBD"
    }
])
string ContractType

@enum([
    {
        value: "artist",
        name: "ARTIST"
    },
    {
        value: "manager",
        name: "MANAGER"
    },
    {
        value: "lawyer",
        name: "LAWYER"
    },
    {
        value: "producer",
        name: "PRODUCER"
    }
])
string AccountType

// Contract operations

@readonly
operation GetContract {
    input: GetContractInput
    output: GetContractOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        ProcessingIncompleteError,
        InternalServerError
    ]
}

structure GetContractInput {
    @required
    contractId: ContractId
}

// The output structure for GetContract matches the Contract resource properties
structure GetContractOutput {
    @required
    contractId: ContractId
    
    @required
    name: String
    
    @required
    type: ContractType
    
    @required
    terms: Document
    
    @required
    qa_sections: QASections // Note: this is returned as "iq_qa" in the response but we map it to qa_sections
    
    @required
    isOwner: Boolean
    
    @required
    ownerId: UserId
    
    @required
    sharedUsers: UserIdList // This field is named differently in the API (sharedUsers vs sharedWith)
}

// This matches the structure of the iq_qa field returned by the API
structure QASections {
    @required
    sections: SectionList
}

list SectionList {
    member: QASection
}

structure QASection {
    @required
    title: String
    
    @required
    questions: QuestionList
}

list QuestionList {
    member: Question
}

structure Question {
    @required
    question: String
    
    @required
    answer: String
}

@readonly
operation ListContracts {
    input: ListContractsInput
    output: ListContractsOutput
    errors: [
        AuthenticationError,
        InternalServerError
    ]
}

structure ListContractsInput {
    // Empty input - authentication handled via Bearer token
}

structure ListContractsOutput {
    @required
    owned: ContractSummaryList
    
    @required
    shared: ContractSummaryList
}

list ContractSummaryList {
    member: ContractSummaryItem
}

// This structure matches the ContractSummary resource's properties
// but is specifically for use in list responses
structure ContractSummaryItem {
    @required
    contractId: ContractId
    
    @required
    name: String
    
    @required
    uploadedOn: Timestamp
    
    @required
    type: ContractType
    
    @required
    status: ContractStatus
    
    @required
    isOwner: Boolean
    
    @required
    ownerId: UserId
    
    sharedWith: UserIdList
}

@idempotent
operation GetUploadURL {
    input: GetUploadURLInput
    output: GetUploadURLOutput
    errors: [
        AuthenticationError,
        ValidationError,
        InternalServerError
    ]
}

structure GetUploadURLInput {
    @required
    name: String
}

structure GetUploadURLOutput {
    @required
    url_info: PresignedPostData
}

structure PresignedPostData {
    @required
    url: String
    
    @required
    fields: Document
}

@idempotent
operation UpdateContract {
    input: UpdateContractInput
    output: UpdateContractOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        ValidationError,
        InternalServerError
    ]
}

structure UpdateContractInput {
    @required
    contractId: ContractId
    
    @required
    name: String
}

structure UpdateContractOutput {
    @required
    success: Boolean
}

@idempotent
operation DeleteContract {
    input: DeleteContractInput
    output: DeleteContractOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure DeleteContractInput {
    @required
    contractId: ContractId
}

structure DeleteContractOutput {
    @required
    success: Boolean
}

@idempotent
operation ShareContract {
    input: ShareContractInput
    output: ShareContractOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        ValidationError,
        InternalServerError
    ]
}

structure ShareContractInput {
    @required
    contractId: ContractId
    
    emailsToAdd: EmailList
    
    emailsToRemove: EmailList
}

list EmailList {
    member: String
}

structure ShareContractOutput {
    @required
    success: Boolean
    
    @required
    contractId: ContractId
    
    @required
    sharedWith: SharedUserDetailsList
    
    added: EmailList
    
    removed: EmailList
    
    invalidRemoves: EmailList
}

list SharedUserDetailsList {
    member: SharedUserDetails
}

structure SharedUserDetails {
    @required
    userId: UserId
    
    @required
    email: String
    
    @required
    sharedTime: Timestamp
}

@readonly
operation GetContractReadURL {
    input: GetContractReadURLInput
    output: GetContractReadURLOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure GetContractReadURLInput {
    @required
    contractId: ContractId
}

structure GetContractReadURLOutput {
    @required
    url: String
}

// User Profile operations

@readonly
operation GetProfile {
    input: GetProfileInput
    output: GetProfileOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure GetProfileInput {
    userId: UserId  // Optional - defaults to authenticated user if not provided
}

structure GetProfileOutput {
    @required
    userId: UserId
    
    @required
    profile: UserProfile
}

structure UserProfile {
    userId: UserId
    firstName: String
    lastName: String
    displayName: String
    email: String
    accountType: AccountType
    bio: String
}

@idempotent
operation UpdateProfile {
    input: UpdateProfileInput
    output: UpdateProfileOutput
    errors: [
        AuthenticationError,
        ValidationError,
        InternalServerError
    ]
}

structure UpdateProfileInput {
    firstName: String
    lastName: String
    displayName: String
    accountType: AccountType
    bio: String
    isOver18: Boolean
}

structure UpdateProfileOutput {
    @required
    success: Boolean
    
    @required
    message: String
    
    @required
    userId: UserId
    
    updatedFields: StringList
}

list StringList {
    member: String
}

@idempotent
operation UploadProfilePicture {
    input: UploadProfilePictureInput
    output: UploadProfilePictureOutput
    errors: [
        AuthenticationError,
        ValidationError,
        InternalServerError
    ]
}

structure UploadProfilePictureInput {
    @required
    image: Base64EncodedImage
    
    userId: UserId  // Optional - defaults to authenticated user if not provided
}

string Base64EncodedImage

structure UploadProfilePictureOutput {
    @required
    success: Boolean
    
    profilePictureURL: String
}

@readonly
operation GetProfilePicture {
    input: GetProfilePictureInput
    output: GetProfilePictureOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure GetProfilePictureInput {
    userId: UserId  // Optional - defaults to authenticated user if not provided
}

structure GetProfilePictureOutput {
    profilePictureURL: String
}

// Utility operations

@readonly
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

// Common structures

document Document

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