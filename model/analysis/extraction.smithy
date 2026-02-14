$version: "2"

metadata suppressions = [
  {
    id: "EnumShape",
    namespace: "equaliq.extraction"
  }
]

namespace equaliq.extraction

use equaliq#StringList
use equaliq#ContractTexts

// General Contract Extraction not directly tied to EQ or IQ analysis

structure ContractExtractionResult {
  @documentation("The contract type here is the one extracted by the model, not necessarily the one set by user")
  extractedType: String

  parties: StringList

  terms: ExtractionTermMap

  variables: ContractVariableMap

  contractTexts: ContractTexts
}

map ExtractionTermMap {
  key: String
  value: ExtractionTerm
}

structure ExtractionTerm {
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

  fixedValues: FixedValueTermInference

  fixedValueGuideline: String

  originalValue: String
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


enum ContractVariableType {
  eq_term = "eq_term"
  discovered_term = "discovered_term"
  external_term = "external_term"
  internal_citation = "internal_citation"
}


structure VariableExtractionResult {
  @required
  variables: ContractVariableMap
}

map ContractVariableMap {
  key: String 
  value: ContractVariable
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

