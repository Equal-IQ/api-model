$version: "2"

namespace equaliq

use equaliq#FileAttachmentList

// Chatbot operations and structures

@http(method: "POST", uri: "/chat")
operation ChatQuery {
    input: ChatQueryInput
    output: ChatQueryOutput
    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

structure ChatQueryInput {
    @required
    query: String
    scope: String
    attachments: FileAttachmentList
}

structure ChatQueryOutput {
    // i'm thinking that we can embed the citations within the chatbot response using a css tag like <cite>, and we can make it highlighted/bold/etc
    @required
    message: String
    
    subpages: SubpageList
}

structure Subpage {
    @required
    title: String
    
    @required
    route: String
}

list SubpageList {
    member: Subpage
}

