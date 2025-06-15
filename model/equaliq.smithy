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
        CreateInvoice
        GetInvoice
        ListInvoices
        AddInvoiceItems
        UpdateInvoice
        FinalizeInvoice
        SendInvoice
        ListCustomers
        ListProducts
        ListPrices
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

//
// Payment/Invoice Operations and Types
//

// Common payment types and enums
@pattern("^[A-Za-z0-9-_]+$")
string InvoiceId

@pattern("^[A-Za-z0-9-_]+$")
string CustomerId

@pattern("^[A-Za-z0-9-_]+$")
string ProductId

@pattern("^[A-Za-z0-9-_]+$")
string PriceId

enum InvoiceStatus {
    DRAFT = "draft"
    OPEN = "open"
    PAID = "paid"
    VOID = "void"
    UNCOLLECTIBLE = "uncollectible"
}

enum CollectionMethod {
    SEND_INVOICE = "send_invoice"
    CHARGE_AUTOMATICALLY = "charge_automatically"
}

// Invoice operations
@http(method: "POST", uri: "/createInvoice")
operation CreateInvoice {
    input: CreateInvoiceInput
    output: CreateInvoiceOutput
    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

structure CreateInvoiceInput {
    @required
    customer: InvoiceCustomer

    @required
    currency: String

    collectionMethod: CollectionMethod

    daysUntilDue: Integer

    description: String

    @required
    lineItems: InvoiceLineItemList

    autoFinalize: Boolean

    metadata: Document
}

structure InvoiceCustomer {
    @required
    email: String

    name: String

    customerId: String

    stripeCustomerId: String
}

list InvoiceLineItemList {
    member: InvoiceLineItem
}

structure InvoiceLineItem {
    @required
    description: String

    @required
    amount: Long

    quantity: Integer

    existingPriceId: String

    existingProductId: String

    productName: String
}

structure CreateInvoiceOutput {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    stripeCustomerId: String

    @required
    status: InvoiceStatus

    @required
    amount: Long

    @required
    currency: String

    @required
    customerEmail: String

    customerName: String

    hostedInvoiceUrl: String

    invoicePdf: String

    @required
    createdAt: Timestamp

    dueDate: Timestamp

    @required
    lineItems: InvoiceLineItemResponseList
}

list InvoiceLineItemResponseList {
    member: InvoiceLineItemResponse
}

structure InvoiceLineItemResponse {
    @required
    description: String

    @required
    amount: Long

    @required
    quantity: Integer

    stripeProductId: String

    stripePriceId: String
}

@http(method: "POST", uri: "/getInvoice")
operation GetInvoice {
    input: GetInvoiceInput
    output: GetInvoiceOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetInvoiceInput {
    @required
    invoiceId: InvoiceId
}

structure GetInvoiceOutput {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    status: String

    @required
    amount: Long

    @required
    currency: String

    @required
    customerEmail: String

    customerName: String

    customerId: String

    description: String

    @required
    createdAt: Timestamp

    dueDate: Timestamp

    paidAt: Timestamp

    hostedInvoiceUrl: String

    invoicePdf: String

    metadata: Document

    lineItems: InvoiceLineItemResponseList
}

@http(method: "POST", uri: "/listInvoices")
operation ListInvoices {
    input: ListInvoicesInput
    output: ListInvoicesOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListInvoicesInput {
    limit: Integer

    status: InvoiceStatus

    customerId: String

    startingAfter: String

    endingBefore: String
}

structure ListInvoicesOutput {
    @required
    invoices: InvoiceListItemList

    @required
    hasMore: Boolean

    totalCount: Integer
}

list InvoiceListItemList {
    member: InvoiceListItem
}

structure InvoiceListItem {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    status: String

    @required
    amount: Long

    @required
    currency: String

    @required
    customerEmail: String

    customerName: String

    description: String

    @required
    createdAt: Timestamp

    dueDate: Timestamp

    hostedInvoiceUrl: String

    metadata: Document
}

@http(method: "POST", uri: "/addInvoiceItems")
operation AddInvoiceItems {
    input: AddInvoiceItemsInput
    output: AddInvoiceItemsOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure AddInvoiceItemsInput {
    @required
    invoiceId: InvoiceId

    @required
    lineItems: InvoiceLineItemList
}

structure AddInvoiceItemsOutput {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    addedItems: AddedInvoiceItemList

    @required
    totalAmount: Long
}

list AddedInvoiceItemList {
    member: AddedInvoiceItem
}

structure AddedInvoiceItem {
    @required
    description: String

    @required
    amount: Long

    @required
    quantity: Integer

    stripeProductId: String

    stripePriceId: String

    @required
    stripeInvoiceItemId: String
}

@http(method: "POST", uri: "/updateInvoice")
operation UpdateInvoice {
    input: UpdateInvoiceInput
    output: UpdateInvoiceOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateInvoiceInput {
    @required
    invoiceId: InvoiceId

    collectionMethod: CollectionMethod

    daysUntilDue: Integer

    description: String

    metadata: Document

    customerEmail: String

    customerName: String
}

structure UpdateInvoiceOutput {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    status: InvoiceStatus

    @required
    collectionMethod: CollectionMethod

    daysUntilDue: Integer

    description: String

    @required
    customerEmail: String

    customerName: String

    @required
    updatedAt: Timestamp
}

@http(method: "POST", uri: "/finalizeInvoice")
operation FinalizeInvoice {
    input: FinalizeInvoiceInput
    output: FinalizeInvoiceOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure FinalizeInvoiceInput {
    @required
    invoiceId: InvoiceId

    autoAdvance: Boolean
}

structure FinalizeInvoiceOutput {
    @required
    invoiceId: InvoiceId

    @required
    stripeInvoiceId: String

    @required
    status: InvoiceStatus

    hostedInvoiceUrl: String

    invoicePdf: String

    @required
    finalizedAt: Timestamp
}

@http(method: "POST", uri: "/sendInvoice")
operation SendInvoice {
    input: SendInvoiceInput
    output: SendInvoiceOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure SendInvoiceInput {
    @required
    invoiceId: InvoiceId

    sendEmail: Boolean

    customMessage: String
}

structure SendInvoiceOutput {
    @required
    invoiceId: InvoiceId

    @required
    status: String

    @required
    sentAt: Timestamp

    hostedInvoiceUrl: String
}

@http(method: "POST", uri: "/listCustomers")
operation ListCustomers {
    input: ListCustomersInput
    output: ListCustomersOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListCustomersInput {
    limit: Integer

    email: String

    startingAfter: String

    endingBefore: String
}

structure ListCustomersOutput {
    @required
    customers: CustomerListItemList

    @required
    hasMore: Boolean

    totalCount: Integer
}

list CustomerListItemList {
    member: CustomerListItem
}

structure CustomerListItem {
    @required
    customerId: CustomerId

    @required
    stripeCustomerId: String

    @required
    email: String

    name: String

    @required
    createdAt: Timestamp

    metadata: Document
}

@http(method: "POST", uri: "/listProducts")
operation ListProducts {
    input: ListProductsInput
    output: ListProductsOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListProductsInput {
    limit: Integer

    active: Boolean

    startingAfter: String

    endingBefore: String
}

structure ListProductsOutput {
    @required
    products: ProductListItemList

    @required
    hasMore: Boolean

    totalCount: Integer
}

list ProductListItemList {
    member: ProductListItem
}

structure ProductListItem {
    @required
    productId: ProductId

    @required
    stripeProductId: String

    @required
    name: String

    description: String

    @required
    active: Boolean

    @required
    createdAt: Timestamp

    updatedAt: Timestamp

    defaultPriceId: String

    metadata: Document
}

@http(method: "POST", uri: "/listPrices")
operation ListPrices {
    input: ListPricesInput
    output: ListPricesOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListPricesInput {
    limit: Integer

    active: Boolean

    currency: String

    productId: String

    startingAfter: String

    endingBefore: String
}

structure ListPricesOutput {
    @required
    prices: PriceListItemList

    @required
    hasMore: Boolean

    totalCount: Integer
}

list PriceListItemList {
    member: PriceListItem
}

structure PriceListItem {
    @required
    priceId: PriceId

    @required
    stripePriceId: String

    @required
    productId: ProductId

    @required
    stripeProductId: String

    @required
    unitAmount: Long

    @required
    currency: String

    @required
    active: Boolean

    @required
    createdAt: Timestamp

    productName: String

    metadata: Document
}

