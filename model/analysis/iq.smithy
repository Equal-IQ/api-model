$version: "2"

namespace equaliq.iq

use equaliq#Url

list IQModeSectionList {
  member: IQModeSection
}

enum IQModeSectionKey {
        EARNINGS = "earnings"
        QUALITY = "qualityOfRights"
        USAGE = "usageObligations"
        AGREEMENT = "agreementLength"
        LIABILITY = "liabilitySafeguards"
}


structure IQModeSection {
  @required
  id: IQModeSectionKey
  @required
  name: String
  @required
  title: String
  @required
  questions: IQModeQuestionsList
}

list IQModeQuestionsList {
    member: IQModeQuestion
}

structure IQModeQuestion {
    @required
    question: String
    @required
    perspective: IQModePerspectiveList
    @required
    glossarizedTerm: IQModeGlossarizedTerm

    ttsSrcUrl: Url
}

list IQModePerspectiveList {
    member: IQModePerspective
}

structure IQModePerspective {
    @required
    party: String
    @required
    perspectiveText: String
}

structure IQModeGlossarizedTerm {
    @required
    name: String
    @required
    definition: String
    @required
    section: String
}