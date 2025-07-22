$version: "2"

namespace equaliq

use equaliq.eq#EqModeData
use equaliq.iq#IqModeData
use equaliq.extraction#ContractExtractionResult
use equaliq.extraction#ExtractionTermMap
use equaliq.extraction#ContractVariableMap
use equaliq.extraction#ContractMarkupResult

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
  ownerId: UserId

  @required
  name: String

  @required
  type: ContractType

  @documentation("v1)")
  eqData: EqModeData

  @documentation("v1")
  iqData: IqModeData

  @documentation("v1")
  contractExtraction: ContractExtractionResult

  sharedWith: UserIdList

  isOwner: Boolean
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
  contractId: ContractId
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
  
  sharedUsers: SharedUserDetailsList

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
  sharedWithUserId: UserId

  @required
  sharedByUserId: UserId

  @required
  sharedWithUserEmail: Email

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

structure TTSItem {
  ttsPrompt: String

}


structure ContractAnalysisRecord {
  @required
  contractId: ContractId
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

  eqCards: EqModeData
  @required
  iqData: IqModeData

  extractedType: ContractType

  parties: StringList

  terms: ExtractionTermMap

  variables: ContractVariableMap

  contractText: ContractMarkupResult

  sharedUsers: SharedUserDetailsList
  hasTTS: Boolean
  isSpecial: Boolean
}