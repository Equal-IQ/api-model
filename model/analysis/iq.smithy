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
  
  id: IQModeSectionKey
  
  name: String
  
  title: String
  
  questions: IQModeQuestionsList
}

list IQModeQuestionsList {
    member: IQModeQuestion
}

structure IQModeQuestion {
    
    question: String
    
    perspective: IQModePerspectiveList
    
    glossarizedTerm: IQModeGlossarizedTerm

    ttsSrcUrl: Url
}

list IQModePerspectiveList {
    member: IQModePerspective
}

structure IQModePerspective {
    
    party: String
    
    perspectiveText: String
}

structure IQModeGlossarizedTerm {
    
    name: String
    
    definition: String
    
    section: String
}