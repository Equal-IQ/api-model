$version: "2"

namespace equaliq.iq

use equaliq#Url

enum IQModeSectionKey {
    EARNINGS = "earnings"
    QUALITY = "qualityOfRights"
    USAGE = "usageObligations"
    AGREEMENT = "agreementLength"
    LIABILITY = "liabilitySafeguards"
}

map IQModePerspectiveMap {
    key: String
    value: IQModePerspective
}

structure IQModePerspective {
    @required
    sections: IQModeSectionMap
}

map IQModeSectionMap {
    key: IQModeSectionKey
    value: IQModeSection
}

structure IQModeSection {
    @required
    id: IQModeSectionKey

    @required
    sectionTitle: String

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
    answer: String

    glossarizedTerm: IQModeGlossarizedTerm

    ttsSrcUrl: Url
}

structure IQModeGlossarizedTerm {
    name: String
    definition: String
    section: String
}
