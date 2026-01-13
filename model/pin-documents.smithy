$version: "2"

namespace equaliq

use equaliq#ContractId
use equaliq#UserId
use equaliq#UuidLikeMixin

/// PIN Document operations for static, shareable contract access
/// These documents are manually configured in the backend with PIN and email allowlist

// PIN Document structures

string PINDocumentId with [UuidLikeMixin]

/// Get PIN document data with PIN and email validation
/// Validates PIN and email, then returns contract data if valid
@http(method: "POST", uri: "/pinDocuments/get")
operation GetPINDocument {
  input: GetPINDocumentInput
  output: GetPINDocumentOutput
  errors: [
    ValidationError
    ResourceNotFoundError
    InternalServerError
  ]
}

structure GetPINDocumentInput {
  @required
  @documentation("PIN document ID from the shareable URL")
  pinDocumentId: PINDocumentId

  @required
  @documentation("4-6 digit PIN code entered by user")
  pin: String

  @required
  @documentation("Email address entered by user")
  email: String
}

structure GetPINDocumentOutput {
  @required
  @documentation("Document title")
  title: String

  @documentation("Optional description")
  description: String

  @required
  @documentation("Full contract data")
  contractData: GetContractOutput

  @documentation("Custom branding settings")
  branding: PINDocumentBranding
}

/// Custom branding for PIN documents
structure PINDocumentBranding {
  @documentation("Logo URL")
  logoUrl: String

  @documentation("Primary brand color (hex)")
  primaryColor: String

  @documentation("Company name")
  companyName: String
}
