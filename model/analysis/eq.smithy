$version: "2"

metadata suppressions = [
  {
    id: "EnumShape",
    namespace: "equaliq.eq"
  }
]

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
  moneyYouReceive = "moneyYouReceive"
  whatYouOwn = "whatYouOwn"
  whatYoureResponsibleFor = "whatYoureResponsibleFor"
  howLongThisDealLasts = "howLongThisDealLasts"
  risksCostsLegalStuff = "risksCostsLegalStuff"
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
  fixed = "fixed"
  indefinite = "indefinite"
  renewable = "renewable"
  other = "other"
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
  moneyYouReceive: EqMoneyCard
  whatYouOwn: EqOwnershipCard
  whatYoureResponsibleFor: EqResponsibilitiesCard
  howLongThisDealLasts: EqDurationCard
  risksCostsLegalStuff: EqLegalCard
  empty: EmptyStructure
}

// EQMode data structure - matches the eqmode field in seniSpecialData
map EqModeCardMap {
  key: EqCardKey
  value: EqModeCard
}

enum EqCardType {
  @documentation("v0")
  a = "a"

  @documentation("v1")
  b = "b"
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