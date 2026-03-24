$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#Email
use equaliq#Url
use equaliq#ISODate
use equaliq#StringList
use equaliq#PageLimit
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError


// Identifiers
string NylasConnectionId with [UuidLikeMixin]
string NylasGrantId
string ThreadMetadataId with [UuidLikeMixin]

// Nylas resource
/// Nylas email integration resource
/// Provides email operations via connected Nylas accounts (v3 API)
/// MVP: Email operations only
resource NylasResource {
    identifiers: { connectionId: NylasConnectionId }
    delete: NylasDisconnectConnection
    operations: [
        NylasListMessages
        NylasGetMessage
        NylasSendMessage
        NylasListThreads
    ]
}

// Email structures matching Nylas v3 API exactly

/// Email participant (sender/recipient)
/// Matches Nylas v3 participant structure
structure EmailParticipant {
    @required
    email: Email
    
    name: String
}

list EmailParticipantList {
    member: EmailParticipant
}

/// Email message
/// Matches Nylas v3 Message object structure
structure NylasMessage {
    /// Nylas message ID
    @required
    id: String

    /// Grant ID that owns this message
    @required
    grantId: NylasGrantId

    /// Thread ID
    threadId: String

    @required
    subject: String

    /// Plain text preview/snippet
    snippet: String

    /// Email body (HTML or plain text)
    body: String

    /// Sender information
    from: EmailParticipantList

    /// Recipients
    to: EmailParticipantList

    cc: EmailParticipantList
    bcc: EmailParticipantList
    replyTo: EmailParticipantList

    /// Unix timestamp (seconds)
    @required
    date: Long

    @required
    unread: Boolean

    starred: Boolean

    /// Folder names/labels
    folders: StringList
}

list NylasMessageList {
    member: NylasMessage
}

/// Thread with enriched metadata
structure NylasThread {
    /// Our database ID
    @required
    threadMetadataId: ThreadMetadataId

    /// Nylas thread ID
    @required
    externalThreadId: String

    @required
    provider: String

    /// Email address of the connected account
    connectionEmail: String

    /// Timeline
    @required
    lastMessageAt: ISODate

    @required
    messageCount: Integer

    /// AI-generated metadata (no PII)
    summary: String
    priority: Integer
    labels: StringList
    ragKeywords: StringList

    /// Processing state
    @required
    analyzed: Boolean

    analyzedAt: ISODate

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

list NylasThreadList {
    member: NylasThread
}

/// Nylas API list response wrapper
structure ListMessagesResponse {
    @required
    requestId: String

    @required
    data: NylasMessageList

    /// Cursor for pagination
    nextCursor: String
}

/// Nylas API single message response wrapper
structure GetMessageResponse {
    @required
    requestId: String

    @required
    data: NylasMessage
}

/// Nylas connection status
/// Note: grantId intentionally excluded - internal Nylas credential, not for frontend
structure NylasConnection {
    @required
    connectionId: NylasConnectionId

    @required
    email: Email

    /// Email provider: 'google', 'microsoft', etc.
    @required
    provider: String

    @required
    enabled: Boolean

    @required
    connectedAt: ISODate

    /// OAuth scopes granted
    scopes: StringList
}

// Thread Operations

/// List threads with enriched metadata
/// Fetches threads from our database (includes AI-generated summary, priority, labels)
/// For live thread data (subject, participants), use NylasGetMessage per message
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "threads", pageSize: "limit")
@http(method: "POST", uri: "/integrations/nylas/threads/list")
operation NylasListThreads {
    input := {
        /// Connection ID to use for this request
        @required
        connectionId: NylasConnectionId

        /// Filter by priority (minimum value)
        minPriority: Integer

        /// Filter by label
        label: String

        /// Filter analyzed threads only
        analyzedOnly: Boolean

        /// Pagination cursor (encoded threadMetadataId)
        nextToken: String

        /// Page size
        limit: PageLimit
    }

    output := {
        @required
        threads: NylasThreadList

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Get a single thread by ID
/// Fetches thread metadata from our database (includes AI-generated summary, priority, labels)
@http(method: "POST", uri: "/integrations/nylas/threads/get")
operation NylasGetThread {
    input := {
        /// Thread metadata ID
        @required
        threadMetadataId: ThreadMetadataId
    }

    output := {
        @required
        thread: NylasThread
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Email Operations (MVP)

/// List messages for authenticated user
/// Maps to Nylas v3: GET /v3/grants/{grant_id}/messages
@http(method: "POST", uri: "/integrations/nylas/messages/list")
operation NylasListMessages {
    input := {
        /// Connection ID to use for this request
        @required
        connectionId: NylasConnectionId

        /// Maximum number of messages to return (default 50, max 200)
        @range(min: 1, max: 200)
        limit: Integer

        /// Pagination cursor from previous response
        cursor: String

        /// Filter by subject
        subject: String

        /// Filter by sender email
        anyEmail: Email

        /// Filter to folder/label
        in: String

        /// Filter unread messages
        unread: Boolean

        /// Filter starred messages
        starred: Boolean

        /// Unix timestamp - messages after this date
        receivedAfter: Long

        /// Unix timestamp - messages before this date
        receivedBefore: Long
    }

    output := {
        @required
        requestId: String

        @required
        data: NylasMessageList

        /// Cursor for next page
        nextCursor: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Get a specific message by ID
/// Maps to Nylas v3: GET /v3/grants/{grant_id}/messages/{message_id}
@http(method: "POST", uri: "/integrations/nylas/messages/get")
operation NylasGetMessage {
    input := {
        /// Connection ID to use for this request
        @required
        connectionId: NylasConnectionId

        @required
        messageId: String
    }

    output := {
        @required
        requestId: String

        @required
        data: NylasMessage
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

/// Send an email message
/// Maps to Nylas v3: POST /v3/grants/{grant_id}/messages/send
@http(method: "POST", uri: "/integrations/nylas/messages/send")
operation NylasSendMessage {
    input := {
        /// Connection ID to use for this request
        @required
        connectionId: NylasConnectionId

        @required
        to: EmailParticipantList

        cc: EmailParticipantList
        bcc: EmailParticipantList
        replyTo: EmailParticipantList

        @required
        subject: String

        /// Email body (HTML or plain text)
        @required
        body: String

        /// Reply to specific message (for threading)
        replyToMessageId: String
    }

    output := {
        @required
        requestId: String

        @required
        data: NylasMessage
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Connection Management Operations

/// Initiate OAuth flow to connect a Nylas account
/// Generates Nylas Hosted Authentication URL
@http(method: "POST", uri: "/integrations/nylas/auth/initiate")
operation NylasInitiateAuth {
    input := {
        /// Optional: Specify email provider hint
        provider: String
    }

    output := {
        @required
        authUrl: Url

        /// State parameter for CSRF validation
        @required
        state: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// OAuth callback handler (/integrations/nylas/auth/callback) is not defined in Smithy
/// It's a raw GET endpoint that accepts query params (code, state) and returns a 302 redirect
/// Similar to Google OAuth callback - handles browser redirects, not API JSON responses

/// List all Nylas connections for authenticated user
@http(method: "POST", uri: "/integrations/nylas/connections/list")
operation NylasListConnections {
    input := {}

    output := {
        @required
        connected: Boolean

        /// List of active connections
        connections: NylasConnectionList
    }

    errors: [
        AuthenticationError
        InternalServerError
    ]
}

list NylasConnectionList {
    member: NylasConnection
}

/// Disconnect a specific Nylas connection (soft delete)
@idempotent
@http(method: "POST", uri: "/integrations/nylas/connections/disconnect")
operation NylasDisconnectConnection {
    input := {
        /// Connection ID to disconnect (required for multi-account)
        @required
        connectionId: NylasConnectionId
    }

    output := {
        @required
        success: Boolean
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}