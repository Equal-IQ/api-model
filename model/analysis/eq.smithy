$version: "2"

namespace equaliq.eq

use equaliq#TermsList
use equaliq#StringList
use equaliq#EmptyStructure
use equaliq#Url

// EQ Mode Structures

structure EqSection {
  @documentation("deprecation path (v0.5)")
  terms: TermsList

  //v1 version
  eqModeData: EQModeData
}

// Special Contract Structures (only the stable ones)
enum EqCardKey {
  MONEY_RECEIVED = "moneyYouReceive"
  OWNERSHIP = "whatYouOwn"
  RESPONSIBILITES = "whatYoureResponsibleFor"
  DURATION = "howLongThisDealLasts"
  LEGAL = "risksCostsLegalStuff"
}

structure EqMoneyCard {
  
  majorNumber: String,

  paidAfterList: StringList,
}

structure EqOwnershipCard {
  
  ownershipTerms: SimpleTermDescriptionList,
}

structure EqResponsibilitesCard {
  
  responsibilites: SimpleTermDescriptionList
}

enum DurationType {
  FIXED = "fixed"
  INDEFINITE = "indefinite"
  RENEWABLE = "renewable"
  OTHER = "other"
}

structure EqDurationCard {
  
  durationType: DurationType

  durationText: String

  durationDetails: SimpleTermDescriptionList
}

structure EqLegalCard {
  
  risks: String
  
  
  costs: String

  
  legal: String
}

union EqCardUniqueData {
  MONEY_RECEIVED: EqMoneyCard
  OWNERSHIP: EqOwnershipCard
  RESPONSIBILITIES: EqResponsibilitesCard 
  DURATION: EqDurationCard
  LEGAL: EqLegalCard
  EMPTY: EmptyStructure
}

// EQMode data structure - matches the eqmode field in seniSpecialData
map EQModeData {
  key: EqCardKey
  value: EQModeCard
}

enum EqCardType {
  @documentation("v0")
  A = "A"
  
  @documentation("v1")
  B = "B"
}

list EQModeCardList {
  member: EQModeCard
}

// Individual EQMode card
structure EQModeCard {
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
  items: EQModeItemList

  @documentation("Deprecated, use the ttsSrcUrl")
  audioSrc: String

  ttsSrcUrl: Url
}

@documentation("Deprecated")
list EQModeItemList {
  member: EQModeItem
}

@documentation("Deprecated")
structure EQModeItem {
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