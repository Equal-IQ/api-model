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
        ExposeTypes
        SignContract
        GetContractSignatures
        UpdateSignatureStatus
        DeleteContractSignature
        CreateComposerContract
        GetComposerContractMeta
        GetComposerContractContent
        UpdateComposerContractMeta
        UpdateComposerContractContent
        SaveComposerContractToVault
        ListComposerContracts
        ListComposerContractVersions
        ArchiveComposerContract
    ]

}

resource ComposerContract {
    identifiers: { contractId: ComposerContractId }
    create: CreateComposerContract
    read: GetComposerContractMeta 
    update: UpdateComposerContractMeta
    delete: ArchiveComposerContract
    list: ListComposerContracts

    operations: [
        GetComposerContractContent,
        UpdateComposerContractContent,
        SaveComposerContractToVault,
        ListComposerContractVersions
    ]
}

// When changing APIs, we sometimes want to expose unified types that aren't directly tied to any API.
structure ExposedTypes { 
  QASectionsList: QASectionsList
}

// This API is used simply to expose types
@http(method: "POST", uri: "/notARealEndpoint")
operation ExposeTypes {
    output: ExposedTypes
}

// Types
@pattern("^[A-Za-z0-9-]+$")
string ContractId

@pattern("^[A-Za-z0-9-]+$")
string UserId

@pattern("^[A-Fa-f0-9-]{36}$")
string ComposerContractId

@pattern("^[A-Fa-f0-9-]{36}$")
string RevisionId

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

enum SignatureStatus {
    SIGNED = "signed"
    DECLINED = "declined"
    PENDING = "pending"
}

enum SignContractResult {
    SUCCESS 
    FAILURE
}

enum SignatureStatus {
    SIGNED = "signed"
    DECLINED = "declined"
    PENDING = "pending"
}

enum SignContractResult {
    SUCCESS 
    FAILURE
}

enum ComposerContractStatus {
    NEW
    CLEAN_IN_VAULT
    DIRTY
    ARCHIVED
}

enum ComposerContractType {
    PRODUCER 
}

enum ComposerContractSection {
    SERVICES
    COMPENSATION
    INTELLECTUAL_PROPERTY
    TERM_AND_TERMINATION
    CONFIDENTIALITY
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
    terms: TermsList

    @required
    qa_sections: String

    @required
    isOwner: Boolean

    @required
    ownerId: UserId

    @required
    sharedWith: UserIdList
}

list QASectionsList {
    member: QASection
}

structure QASection {
    @required
    section: String
    
    @required
    qa: QAList
}

list QAList {
    member: QA
}

structure QA {
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
    isComposerGenerated: Boolean
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

// Contract Terms structures
list TermsList {
    member: Term
}

structure Term {
    @required
    name: String
    
    @required
    definition: String
    
    @required
    unitType: String
    
    citation: String
    
    fixedValues: FixedValueTermInference
    
    // Additional properties will be serialized as part of the Document
}

structure FixedValueTermInference {
    @required
    primary: FixedTermValue
    
    subterms: FixedTermValueList
}

list FixedTermValueList {
    member: FixedTermValue
}

structure FixedTermValue {
    @required
    unit: String
    
    @required
    value: String
    
    name: String
    
    numericValue: Float
    
    condition: String
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

@idempotent
@http(method: "POST", uri: "/sign")
operation SignContract {
    input: SignContractInput
    output: SignContractOutput
    errors: [
        AuthenticationError,
        ValidationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure SignContractInput {
    @required
    contractId: String
    @required
    status: SignatureStatus
}

structure SignContractOutput {
    @required
    result: SignContractResult
    message: String
}


@http(method: "POST", uri: "/getContractSignatures")
operation GetContractSignatures {
    input: GetContractSignaturesInput
    output: GetContractSignaturesOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure GetContractSignaturesInput {
    @required
    contractId: String
}

list SignatureList {
    member: ContractSignature
}

structure ContractSignature {
    userId: String
    status: SignatureStatus
    timestamp: Timestamp
}

structure GetContractSignaturesOutput {
    contractId: String
    signatures: SignatureList
}

@http(method: "POST", uri: "/updateSignatureStatus")
operation UpdateSignatureStatus {
    input: UpdateSignatureStatusInput
    output: UpdateSignatureStatusOutput
    errors: [
        AuthenticationError,
        ValidationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}
structure UpdateSignatureStatusInput {
    @required
    contractId: ContractId
    @required
    status: SignatureStatus
}

structure UpdateSignatureStatusOutput {
    @required
    result: SignContractResult
    @required
    message: String
}


@idempotent
@http(method: "POST", uri: "/deleteContractSignature")
operation DeleteContractSignature {
    input: DeleteContractSignatureInput
    output: DeleteContractSignatureOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure DeleteContractSignatureInput {
    @required
    contractId: String
}

structure DeleteContractSignatureOutput {
    result: SignContractResult
    message: String
}

structure ComposerContractMeta {
    contractId: ComposerContractId
    revisionId: String
    title: String
    type: ComposerContractType
    status: ComposerContractStatus
    createdAt: Timestamp
    updatedAt: Timestamp
    revisionHistory: RevisionIdList
}

list RevisionIdList {
    member: String
}

structure ComposerContractContent {
    sections: ComposerContractSectionList
}

structure ComposerContractData {
    meta: ComposerContractMeta
    content: ComposerContractContent
}

list ComposerContractSectionList {
  member: SectionUnion
}

union SectionUnion {
  term: TermSection
  clause: ClauseSection
  // more structured section types
}

structure TermSection {
    sectionId: ComposerContractSection
    name: String
    definition: String
    citation: String
    unit: String
}

structure ClauseSection {
    sectionId: ComposerContractSection
    text: String
}


@idempotent
@http(method: "POST", uri: "/composer/create")
operation CreateComposerContract {
    input: CreateComposerContractInput
    output: CreateComposerContractOutput
}

structure CreateComposerContractInput {
    @required
    title: String
    @required
    type: ComposerContractType
    formDetails: ComposerFormData
    sourceRevisionId: RevisionId
}
structure CreateComposerContractOutput {
    contract: ComposerContractData
}

structure ComposerFormData {
    clientName: String
    providerName: String
    date: String 
}

@readonly
@http(method: "POST", uri: "/composer/getMeta")
operation GetComposerContractMeta {
  input: GetComposerContractInput
  output: GetComposerContractMetaOutput
}

structure GetComposerContractMetaOutput {
  meta: ComposerContractMeta
}

@http(method: "POST", uri: "/composer/getContent")
operation GetComposerContractContent {
  input: GetComposerContractInput
  output: GetComposerContractContentOutput
}
structure GetComposerContractInput {
  @required
  contractId: ComposerContractId
}

structure GetComposerContractContentOutput {
  content: ComposerContractContent
}


@idempotent
@http(method: "POST", uri: "/composer/updateMeta")
operation UpdateComposerContractMeta {
    input: UpdateComposerContractMetaInput
    output: UpdateComposerContractMetaOutput
}

structure UpdateComposerContractMetaInput {
    @required
    contractId: ComposerContractId
    title: String
    sections: ComposerContractSectionList
    status: ComposerContractStatus
}

structure UpdateComposerContractMetaOutput {
    contract: ComposerContractData
}

@http(method: "POST", uri: "/composer/updateContent")
operation UpdateComposerContractContent {
    input: UpdateComposerContractContentInput
    output: UpdateComposerContractContentOutput
}

structure UpdateComposerContractContentInput {
    @required
    contractId: ComposerContractId
    sections: ComposerContractSectionList
}

structure UpdateComposerContractContentOutput {
    contract: ComposerContractData
}

@readonly
@http(method: "POST", uri: "/composer/list")
operation ListComposerContracts {
    input: ListComposerContractsInput
    output: ListComposerContractsOutput
}

structure ListComposerContractsInput {
  // temp - ask Parker
}

list ComposerContractMetaList {
    member: ComposerContractMeta
}

structure ListComposerContractsOutput {
    contracts: ComposerContractMetaList
}

@http(method: "POST", uri: "/composer/listVersions")
operation ListComposerContractVersions {
    input: GetComposerContractInput
    output: ListComposerContractVersionsOutput
}

structure ListComposerContractVersionsOutput {
    contractId: ComposerContractId
    versions: ComposerContractMetaList
}

@http(method: "POST", uri: "/composer/publish")
operation SaveComposerContractToVault {
    input: SaveComposerContractToVaultInput
    output: SaveComposerContractToVaultOutput
}

structure SaveComposerContractToVaultInput {
    @required
    contractId: ComposerContractId
}

structure SaveComposerContractToVaultOutput {
    @required
      message: String
}

@idempotent
@http(method: "POST", uri: "/composer/archive")
operation ArchiveComposerContract {
    input: ArchiveComposerContractInput
    output: ArchiveComposerContractOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure ArchiveComposerContractInput {
    @required
    contractId: ComposerContractId
}

structure ArchiveComposerContractOutput {
    @required
    message: String
}

