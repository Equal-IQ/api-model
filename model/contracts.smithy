$version: "2"

namespace equaliq

use equaliq.eq#EqSection
use equaliq.eq#EQModeCardList
use equaliq.iq#IQModePerspectiveMap

// Contract structures

string ContractId with [UuidLikeMixin]

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
    SERVICES = "services"
    TBD = "tbd"
}

enum ContractVariableType {
    EQ_TERM = "eq_term"
    DISCOVERED_TERM = "discovered_term"
    EXTERNAL_TERM = "external_term"
    INTERNAL_CITATION = "internal_citation"
}


structure IqSection {
  @documentation("deprecation path (v0.5)")
  qa_sections: QASectionsList

  // v1 version

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

    @documentation("deprecation path (v0)")
    terms: TermsList

    @documentation("deprecation path (v0)")
    qa_sections: String

    @documentation("deprecation path (v0)")
    eq_section: EqSection
    @documentation("deprecation path (v0)")
    iq_section: IqSection

    @documentation("deprecation path (v0.5)")
    eqmode: Document

    @documentation("deprecation path (v0.5)")
    sections: Document

    @documentation("v1")
    eq: EQModeCardList

    @documentation("v1")
    iq: IQModePerspectiveMap

    @documentation("v1")
    contractViewerText: String


    @required
    isOwner: Boolean

    @required
    ownerId: UserId

    @required
    sharedWith: UserIdList
}

@http(method: "POST", uri: "/getSpecialContract")
operation GetSpecialContract {
    input: GetSpecialContractInput
    output: GetSpecialContractOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ProcessingIncompleteError
        InternalServerError
    ]
}

structure GetSpecialContractInput {
    @required
    contractId: ContractId
}

structure GetSpecialContractOutput {
    @required
    contractId: ContractId

    @required
    name: String

    @required
    type: ContractType

    @required
    eqmode: Document

    @required
    sections: Document

    @required
    isOwner: Boolean

    @required
    ownerId: UserId

    @required
    sharedWith: UserIdList
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
    
    
    @documentation("Deprecation path (v0.5)")
    owned: ContractSummaryList

    @documentation("Deprecation path (v0.5)")
    shared: ContractSummaryList

    @documentation("v1")
    contracts: ContractMetadataList
}

@http(method: "POST", uri: "/listSpecialContracts")
operation ListSpecialContracts {
    input: ListSpecialContractsInput
    output: ListSpecialContractsOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListSpecialContractsInput {
    // Empty input - authentication handled via Bearer token
}

structure ListSpecialContractsOutput {
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

list ContractMetadataList {
    member: ContractMetadata
}

structure ContractMetadata {
    @required
    id: ContractId
    @required
    name: String
    @required
    type: ContractType
    @required
    status: ContractStatus
    @required
    uploadedOn: ISODate
    @required
    ownerId: UserId
    
    sharedWith: SharedUserDetailsList

    isOwner: Boolean
    hasTTS: Boolean

    // Flag for demo / differently-shaped contract data
    isSpecial: Boolean

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
    url: Url

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
    email: Email

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
    url: Url
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

// Contract variable structures
structure ContractVariable {
    @required
    name: String

    @required
    type: ContractVariableType

    @required
    id: String

    // the definition/explanation for this variable
    value: String

    // 1-10 difficulty level (external terms only)
    level: Integer

    confidence: Float

    // character position
    firstOccurrence: Integer

    // surrounding text
    context: String

    // alternative forms
    variations: StringList

    // for internal citations
    referencedSection: String

    // where the term is defined (e.g., "Section 7(ii)(c)(I)") - for EQ_TERM and DISCOVERED_TERM only
    definitionCitation: String
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

// Contract analysis service result types

structure SummaryResult {
    @required
    summary: ContractSummary
}

structure ContractSummary {
    @required
    type: String
    
    @required
    parties: StringList
}

structure EQResult {
    @required
    terms: CompleteTermList
}

list CompleteTermList {
    member: CompleteTerm
}

structure CompleteTerm {
    @required
    name: String
    
    @required
    definition: String
    
    @required
    unitType: String
    
    @required
    explanation: String
    
    @required
    notes: String
    
    @required
    citation: String
    
    @required
    fixedValues: FixedValueTermInference
    
    fixedValueGuideline: String
    
    originalValue: String
}

structure IQResult {
    @required
    qa: QASectionsList
    
    @required
    perspectiveQA: PerspectiveQASet
}

map PerspectiveQASet {
    key: String
    value: QASectionsList
}

structure VariableExtractionResult {
    @required
    variables: ContractVariableList
}

list ContractVariableList {
    member: ContractVariable
}

structure ContractMarkupResult {
    @required
    markedUpContract: String
    
    @required
    statistics: MarkupStatistics
}

structure MarkupStatistics {
    @required
    originalLength: Integer
    
    @required
    markedUpLength: Integer
    
    @required
    totalVariables: Integer
    
    @required
    processingTimeSeconds: Float
    
    @required
    chunksProcessed: Integer
}

structure IQAnswersMarkupResult {
    @required
    markedUpPerspectiveQA: PerspectiveQASet
}

// Sections structure - matches the sections field in seniSpecialData
list SpecialContractSectionsList {
    member: SpecialContractSection
}

structure SpecialContractSection {
    @required
    id: String
    
    @required
    name: String
    
    @required
    title: String
    
    @required
    questions: SpecialContractQuestionList
}

list SpecialContractQuestionList {
    member: SpecialContractQuestion
}

structure SpecialContractQuestion {
    @required
    question: String
    
    @required
    perspective: QuestionPerspective
    
    @required
    glossarizedTerm: GlossarizedTerm
    
    @required
    audioSrc: QuestionAudioSrc
}

// Supporting structures for questions
structure QuestionPerspective {
    consultant: String
    company: String
}

structure QuestionAudioSrc {
    consultant: String
    company: String
}

structure GlossarizedTerm {
    
    name: String
    
    
    definition: String
    
    
    section: String
}

// Deprecated. Currently, used for SpecialContract only. Use alternative for real contract.
@http(method: "POST", uri: "/getTTSURLs")
operation GetTTSURLs {
    input: GetTTSURLsInput
    output: GetTTSURLsOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Deprecated. Currently, used for SpecialContract only. Use alternative for real contract.
structure GetTTSURLsInput {
    @required
    contractId: ContractId
}

// Deprecated. Currently, used for SpecialContract only. Use alternative for real contract.
structure GetTTSURLsOutput {
    @required
    contractId: ContractId
    
    @required
    ttsSrcUrl: TTSPresignedUrlMap
}

// Deprecated. Currently, used for SpecialContract only. Use alternative for real contract.
// Map of audio source IDs to presigned URLs
map TTSPresignedUrlMap {
    key: String   // AudioSrcId
    value: Url // Presigned S3 URL
}