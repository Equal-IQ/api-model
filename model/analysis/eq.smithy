$version: "2"

namespace equaliq.eq

use equaliq#StringList
use equaliq#EmptyStructure
use equaliq#Url

// EQ Mode Structures

structure EqModeData {
  cards: EqModeCardMap
}

// Special Contract Structures (only the stable ones)
enum EqCardKey {
  MONEY_RECEIVED = "moneyYouReceive"
  OWNERSHIP = "whatYouOwn"
  RESPONSIBILITIES = "whatYoureResponsibleFor"
  DURATION = "howLongThisDealLasts"
  LEGAL = "risksCostsLegalStuff"
}

structure EqMoneyCard {
  @required
  majorNumber: String,

  @required
  paidAfterList: StringList,
}

structure EqOwnershipCard {
  @required
  ownershipTerms: SimpleTermDescriptionList,
}

structure EqResponsibilitiesCard {
  @required
  responsibilities: SimpleTermDescriptionList
}

enum DurationType {
  FIXED = "fixed"
  INDEFINITE = "indefinite"
  RENEWABLE = "renewable"
  OTHER = "other"
}

structure EqDurationCard {
  @required
  durationType: DurationType

  @required
  durationText: String

  durationDetails: SimpleTermDescriptionList
}

structure EqLegalCard {
  @required
  risks: String

  @required
  costs: String

  @required
  legal: String
}

union EqCardUniqueData {
  MONEY_RECEIVED: EqMoneyCard
  OWNERSHIP: EqOwnershipCard
  RESPONSIBILITIES: EqResponsibilitiesCard 
  DURATION: EqDurationCard
  LEGAL: EqLegalCard
  EMPTY: EmptyStructure
}

// EQMode data structure - matches the eqmode field in seniSpecialData
map EqModeCardMap {
  key: EqCardKey
  value: EqModeCard
}

enum EqCardType {
  @documentation("v0")
  A = "A"
  
  @documentation("v1")
  B = "B"
}

// Individual EqMode card
structure EqModeCard {
  @required
  id: EqCardKey
  
  @required
  title: String
  
  @required
  type: EqCardType

  @required
  cardUniqueData: EqCardUniqueData
  
  @documentation("Deprecated, use subTitle Instead")
  eqTitle: String
  subTitle: String

  @documentation("Deprecated, this should be in the in a custom subtype")
  totalAdvance: String

  @documentation("Deprecated, this should be in the in a custom subtype")
  items: EqModeItemList

  @documentation("Deprecated, use the ttsSrcUrl")
  audioSrc: String

  ttsSrcUrl: Url

  flags: EqModeCardFlagMap
}

enum FlagSeverity {
  CRITICAL = "critical"
  WARN = "warn"
  INFO = "info"
  POSITIVE = "positive"
}

structure EqModeCardFlag {
  @required
  severity: FlagSeverity

  @required
  context: String
}

map EqModeCardFlagMap {
  key: String
  value: EqModeCardFlag
}

@documentation("Deprecated")
list EqModeItemList {
  member: EqModeItem
}

@documentation("Deprecated")
structure EqModeItem {
  title: String
  value: String
}

structure SimpleTermDescription {
  @required
  title: String

  @required
  description: String
}

list SimpleTermDescriptionList {
  member: SimpleTermDescription
}