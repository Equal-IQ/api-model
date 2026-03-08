$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#Email
use equaliq#Url
use equaliq#ISODate
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Nylas email integration resource
/// Provides email operations via connected Nylas accounts (v3 API)
/// MVP: Email operations only

// Identifiers
string NylasConnectionId with [UuidLikeMixin]
string NylasGrantId

// Nylas resource
resource NylasResource {
    identifiers: { connectionId: NylasConnectionId }
}

// Email structures matching Nylas v3 API exactly

/// Email participant (sender/recipient)
/// Matches Nylas v3 participant structure
structure EmailParticipant {
    email: Email
    name: String
}

list EmailParticipantList {
    member: EmailParticipant
}

list StringList {
    member: String
}

/// Email message
/// Matches Nylas v3 Message object structure
structure NylasMessage {
    /// Nylas message ID
    @required
    id: String

    /// Grant ID that owns this message
    @required
    grantId: String

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
structure NylasConnection {
    @required
    connectionId: NylasConnectionId

    @required
    grantId: NylasGrantId

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

/// OAuth initiation response
structure NylasAuthUrl {
    @required
    authUrl: Url

    /// Optional state parameter for CSRF protection
    state: String
}

// Email Operations (MVP)

/// List messages for authenticated user
/// Maps to Nylas v3: GET /v3/grants/{grant_id}/messages
@http(method: "POST", uri: "/integrations/nylas/messages/list")
operation NylasListMessages {
    input := {
        /// Maximum number of messages to return (default 50, max 200)
        limit: Integer

        /// Pagination cursor from previous response
        cursor: String

        /// Filter by subject
        subject: String

        /// Filter by sender email
        anyEmail: String

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
        state: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Handle OAuth callback from Nylas
/// Exchanges authorization code for grant ID
@http(method: "POST", uri: "/integrations/nylas/auth/callback")
operation NylasHandleAuthCallback {
    input := {
        @required
        code: String

        /// State parameter from initiation (for CSRF validation)
        state: String
    }

    output := {
        @required
        connection: NylasConnection
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Get connection status for authenticated user
@http(method: "POST", uri: "/integrations/nylas/connection/status")
operation NylasGetConnectionStatus {
    input := {}

    output := {
        @required
        connected: Boolean

        /// Connection details if connected
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

/// Disconnect Nylas account (soft delete)
@idempotent
@http(method: "POST", uri: "/integrations/nylas/connection/disconnect")
operation NylasDisconnectConnection {
    input := {
        /// Connection ID to disconnect (required for multi-account)
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