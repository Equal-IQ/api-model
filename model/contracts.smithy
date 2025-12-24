$version: "2"

namespace equaliq

use equaliq.eq#EqModeData
use equaliq.iq#IqModeData
use equaliq.extraction#ContractExtractionResult
use equaliq.extraction#ExtractionTermMap
use equaliq.extraction#ContractVariableMap
use equaliq#TaggedText
use equaliq#PlainText

// Contract structures

string ContractId with [UuidLikeMixin]

enum ContractStatus {
  PROCESSING = "processing"
  AWAITING_UPLOAD = "awaiting_upload"
  EXTRACTING_TEXT = "extracting_text"
  EQ_GENERATION = "eq_generation"
  IQ_GENERATION = "iq_generation"
  VARIABLE_EXTRACTION = "variable_extraction"
  CONTRACT_MARKUP = "contract_markup"
  TTS_GENERATION = "tts_generation"
  COMPLETE = "complete"
  ERROR = "error"
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
  
  ownerOrgId: OrgId

  @required
  name: String

  @required
  type: String

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
  type: String

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
  orgId: OrgId
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
  type: String

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
  type: String
  @required
  status: ContractStatus
  @required
  uploadedOn: ISODate
  @required
  ownerId: UserId

  ownerOrgId: OrgId

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

  orgId: OrgId
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
  @required
  contractId: ContractId
  @required
  ttsFileName: String // file name in the S3 bucket: (contractId/ttsFileName). Also matches to the card/question in the contract data itself
  @required
  ttsPrompt: String

}

structure ContractTexts {
  originalText: PlainText
  taggedText: TaggedText
}

structure ContractAnalysisRecord {
  @required
  contractId: ContractId
  @required
  name: String
  @required
  type: String
  @required
  status: ContractStatus
  @required
  uploadedOn: ISODate
  @required
  ownerId: UserId

  eqCards: EqModeData
  @required
  iqData: IqModeData

  extractedType: String

  parties: StringList

  terms: ExtractionTermMap

  variables: ContractVariableMap

  contractTexts: ContractTexts

  sharedUsers: SharedUserDetailsList
  hasTTS: Boolean
  isSpecial: Boolean
}