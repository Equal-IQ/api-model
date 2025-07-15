$version: "2"

namespace equaliq.iq

use equaliq#Url
use equaliq#TaggedText

structure IqModeData {
  iqModeData: IqModePerspectiveMap
}

enum IqModeSectionKey {
  EARNINGS = "earnings"
  QUALITY = "qualityOfRights"
  USAGE = "usageObligations"
  AGREEMENT = "agreementLength"
  LIABILITY = "liabilitySafeguards"
}

map IqModePerspectiveMap {
  key: String
  value: IqModePerspective
}

structure IqModePerspective {
  @required
  sections: IqModeSectionMap
}

map IqModeSectionMap {
  key: IqModeSectionKey
  value: IqModeSection
}

structure IqModeSection {
  @required
  id: IqModeSectionKey

  @required
  sectionTitle: String

  @required
  questions: IqModeQuestionsList
}

list IqModeQuestionsList {
  member: IqModeQuestion
}

structure IqModeQuestion {
  @required
  question: TaggedText

  @required
  answer: TaggedText

  ttsSrcUrl: Url
}
