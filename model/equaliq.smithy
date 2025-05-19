$version: "2"

namespace equaliq

use aws.protocols#restJson1

/// Equal IQ API Service
/// Provides contract management, upload, sharing, and user profile functionality
@restJson1
service EqualIQ {
    version: "2023-01-01"
    operations: [
        GetContract
        ListContracts
        GetUploadURL
        UpdateContract
        DeleteContract
        ShareContract
        GetContractReadURL
        GetProfile
        GetProfilePicture
        UploadProfilePicture
        UpdateProfile
        Ping
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

enum ContractStatus {
    PROCESSING = "processing"
    COMPLETE = "complete"
    ERROR = "error"
    AWAITING_UPLOAD = "awaiting_upload"
}

enum ContractType {
    RECORDING = "recording"
    PUBLISHING = "publishing"
    MANAGEMENT = "management"
    PRODUCER = "producer"
    TBD = "tbd"
}

enum AccountType {
    ARTIST = "artist"
    MANAGER = "manager"
    LAWYER = "lawyer"
    PRODUCER = "producer"
    PUBLISHER = "publisher"
}

// Contract operations
@http(method: "POST", uri: "/getContract")
operation GetContract {
    input: GetContractInput
    output: GetContractOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ProcessingIncompleteError
        InternalServerError
    ]
}

structure GetContractInput {
    @required
    contractId: ContractId
}

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
    iq_qa: QASections

    @required
    isOwner: Boolean

    @required
    ownerId: UserId

    @required
    sharedWith: UserIdList
}

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

@http(method: "POST", uri: "/listContracts")
operation ListContracts {
    input: ListContractsInput
    output: ListContractsOutput
    errors: [
        AuthenticationError
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
    sharedUsers: UserIdList
    sharedEmails: EmailList
}

@idempotent
@http(method: "POST", uri: "/uploadURL")
operation GetUploadURL {
    input: GetUploadURLInput
    output: GetUploadURLOutput
    errors: [
        AuthenticationError
        ValidationError
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
@http(method: "POST", uri: "/updateContract")
operation UpdateContract {
    input: UpdateContractInput
    output: UpdateContractOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
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
@http(method: "POST", uri: "/deleteContract")
operation DeleteContract {
    input: DeleteContractInput
    output: DeleteContractOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
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
@http(method: "POST", uri: "/shareContract")
operation ShareContract {
    input: ShareContractInput
    output: ShareContractOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
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

@http(method: "POST", uri: "/getContractReadURL")
operation GetContractReadURL {
    input: GetContractReadURLInput
    output: GetContractReadURLOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
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
@http(method: "POST", uri: "/getProfile")
operation GetProfile {
    input: GetProfileInput
    output: GetProfileOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetProfileInput {
    userId: UserId

    // Optional - defaults to authenticated user if not provided
}

structure GetProfileOutput {
    @required
    userId: UserId

    @required
    profile: UserProfile
}

@http(method: "POST", uri: "/getProfilePicture")
operation GetProfilePicture {
    input: GetProfilePictureInput
    output: GetProfilePictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetProfilePictureInput {
    userId: UserId

    // Optional - defaults to authenticated user if not provided
}

structure GetProfilePictureOutput {
    @required
    profilePictureURL: String
}


@http(method: "POST", uri: "/uploadProfilePicture")
operation UploadProfilePicture {
    input: UploadProfilePictureInput
    output: UploadProfilePictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure UploadProfilePictureInput {
  image: String,
  userId: UserId
}

structure UploadProfilePictureOutput {
    message: String
    picture_id: String
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
@http(method: "POST", uri: "/updateProfile")
operation UpdateProfile {
    input: UpdateProfileInput
    output: UpdateProfileOutput
    errors: [
        AuthenticationError
        ValidationError
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
