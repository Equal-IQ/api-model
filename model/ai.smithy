$version: "2"

namespace equaliq

// ─── Enums ───────────────────────────────────────────────────────────────────

/// Scope for AI context selection
enum AiScopeId {
    contract = "contract"
    deal = "deal"
    global = "global"
}

/// Message author role
enum MessageRole {
    user = "user"
    assistant = "assistant"
}

/// Run execution status
enum RunStatus {
    in_progress = "in_progress"
    complete = "complete"
    failed = "failed"
    cancelled = "cancelled"
}

/// Step execution mode
enum StepMode {
    quick_response = "quick_response"
    full_cycle = "full_cycle"
}

/// Revision lifecycle status
enum RevisionStatus {
    pending = "pending"
    applied = "applied"
    rejected = "rejected"
    failed = "failed"
}

/// Citation source type
enum CitationSourceType {
    legal_kb = "legal_kb"
    app_kb = "app_kb"
    user_document = "user_document"
    external = "external"
}

/// Diff operation type
enum DiffOperationType {
    insert = "insert"
    delete = "delete"
    replace = "replace"
}

/// Risk level for a change
enum RiskLevel {
    low = "low"
    medium = "medium"
    high = "high"
}

// ─── ID Types ────────────────────────────────────────────────────────────────

string ConversationId with [UuidLikeMixin]
string MessageId with [UuidLikeMixin]
string RunId with [UuidLikeMixin]
string RevisionId with [UuidLikeMixin]
string RunStepId with [UuidLikeMixin]
string CitationId with [UuidLikeMixin]

// ─── List Types ──────────────────────────────────────────────────────────────

list CitationList {
    member: Citation
}

// ─── Resources ───────────────────────────────────────────────────────────────

resource ConversationResource {
    identifiers: { conversationId: ConversationId }
    create: CreateConversation
    read: GetConversation
    operations: [SendMessage]
}

resource RunResource {
    identifiers: { runId: RunId }
    read: GetRun
    delete: CancelRun
    operations: [ListRunRevisions]
}

resource RevisionResource {
    identifiers: { revisionId: RevisionId }
    operations: [ApplyRevision, RejectRevision]
}

// ─── Entity Structures ──────────────────────────────────────────────────────

structure Conversation {
    @required
    conversationId: ConversationId

    @required
    userId: UserId

    @required
    dealId: DealId

    @required
    scopeId: AiScopeId

    /// File IDs selected by the user for this conversation
    selectedFileIds: FileIdList

    /// Conversation title (auto-generated or user-set)
    title: String

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure Message {
    @required
    messageId: MessageId

    @required
    conversationId: ConversationId

    @required
    role: MessageRole

    @required
    content: String

    /// Run that produced this message (assistant messages only)
    runId: RunId

    /// Citations included in the response (assistant messages only)
    citations: CitationList

    /// Number of agent cycles in the run (assistant messages only)
    cycleCount: Integer

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure Run {
    @required
    runId: RunId

    @required
    conversationId: ConversationId

    @required
    messageId: MessageId

    @required
    status: RunStatus

    /// Serialized agent context (working memory, plan, ledgers) — internal JSONB
    context: Document

    @required
    currentStep: Integer

    @required
    dealId: DealId

    @required
    contractFileId: FileId

    @required
    scopeId: AiScopeId

    /// Files selected by the user at run creation
    selectedFileIds: FileIdList

    /// When the run completed
    completedAt: ISODate

    /// Error message if run failed
    errorMessage: String

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure Revision {
    @required
    revisionId: RevisionId

    @required
    runId: RunId

    @required
    stepNumber: Integer

    @required
    targetFileId: FileId

    @required
    targetFileName: String

    /// Section hint for locating the change
    sectionHint: String

    @required
    rawDiff: RawDiffOperation

    /// Processed diff with computed positions and metadata
    processedDiff: ProcessedDiffOperation

    @required
    status: RevisionStatus

    /// When the revision was applied
    appliedAt: ISODate

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure StepAuditRecord {
    @required
    runStepId: RunStepId

    @required
    runId: RunId

    @required
    stepNumber: Integer

    @required
    mode: StepMode

    /// Reasoning output text
    reasoning: String

    /// Tool calls made during this step — JSONB
    toolCalls: Document

    /// Tool results received during this step — JSONB
    toolResults: Document

    /// Response text (for quick_response mode)
    response: String

    /// Status message generated
    statusMessage: String

    @required
    durationMs: Long

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

// ─── Sub-Structures ─────────────────────────────────────────────────────────

structure Citation {
    @required
    id: CitationId

    @required
    sourceType: CitationSourceType

    @required
    sourceId: String

    @required
    sourceName: String

    @required
    excerpt: String

    /// Location within the source (section, page)
    location: String

    /// URL if applicable
    url: String
}

structure RawDiffOperation {
    /// Human-readable document name
    documentReference: String

    /// Section reference (e.g., "8.2" or "Indemnification")
    section: String

    /// Clause ID if available
    clauseId: String

    @required
    oldText: String

    @required
    newText: String

    @required
    reason: String

    /// Legal basis for the change
    legalRationale: String

    /// Risk considerations
    riskNote: String
}

structure ProcessedDiffOperation {
    @required
    id: String

    @required
    type: DiffOperationType

    @required
    oldText: String

    @required
    newText: String

    @required
    reason: String

    legalRationale: String

    @required
    location: DiffLocation

    @required
    validation: DiffValidation

    @required
    impact: DiffImpact

    @required
    preview: DiffPreview
}

structure DiffLocation {
    section: String
    clauseId: String
    path: String
    range: CharacterRange
    lineRange: LineRange
    context: String
}

structure CharacterRange {
    @required
    start: Integer

    @required
    end: Integer
}

structure LineRange {
    @required
    startLine: Integer

    @required
    endLine: Integer

    startColumn: Integer
    endColumn: Integer
}

structure DiffValidation {
    @required
    textFound: Boolean

    multipleMatches: Integer

    /// Match locations if multiple found
    matchLocations: CharacterRangeList
}

list CharacterRangeList {
    member: CharacterRange
}

structure DiffImpact {
    @required
    riskLevel: RiskLevel

    @required
    affectedParties: StringList

    @required
    requiresApproval: Boolean

    relatedClauses: StringList
}

structure DiffPreview {
    @required
    before: String

    @required
    after: String

    @required
    highlighted: Boolean
}

// ─── Operations: Conversations ──────────────────────────────────────────────

@http(method: "POST", uri: "/ai/conversations")
operation CreateConversation {
    input := {
        @required
        dealId: DealId

        @required
        scopeId: AiScopeId

        /// Files selected by the user
        selectedFileIds: FileIdList

        /// Optional title
        title: String
    }

    output := {
        @required
        conversation: Conversation
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

@readonly
@http(method: "GET", uri: "/ai/conversations/{conversationId}")
operation GetConversation {
    input := {
        @required
        @httpLabel
        conversationId: ConversationId
    }

    output := {
        @required
        conversation: Conversation

        @required
        messages: MessageMap
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

/// Send a message to a conversation. Creates a run and streams SSE events.
///
/// Streaming behavior: This endpoint returns an SSE stream, not a single JSON response.
/// The stream emits the following event types:
/// - run_started — { runId, conversationId }
/// - step_complete — { stepNumber, mode, status, statusMessage, durationMs }
/// - response_chunk — { text }
/// - run_complete — { runId, response, revisions[], citations[], cycleCount }
/// - run_error — { error }
/// - run_cancelled — { runId }
///
/// The output structure below represents the final accumulated result.
@http(method: "POST", uri: "/ai/conversations/{conversationId}/messages")
operation SendMessage {
    input := {
        @required
        @httpLabel
        conversationId: ConversationId

        @required
        message: String

        /// Primary contract file for this run
        @required
        contractFileId: FileId

        /// Override scope for this message (defaults to conversation scope)
        scopeId: AiScopeId

        /// Override selected files for this message
        selectedFileIds: FileIdList
    }

    output := {
        @required
        runId: RunId

        @required
        conversationId: ConversationId

        @required
        assistantMessage: Message
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ─── Operations: Runs ───────────────────────────────────────────────────────

@readonly
@http(method: "GET", uri: "/ai/runs/{runId}")
operation GetRun {
    input := {
        @required
        @httpLabel
        runId: RunId

        /// Include step audit records in the response
        @httpQuery("includeSteps")
        includeSteps: Boolean
    }

    output := {
        @required
        run: Run

        /// Step audit records keyed by runStepId (present when includeSteps=true)
        steps: StepAuditRecordMap
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@idempotent
@http(method: "DELETE", uri: "/ai/runs/{runId}")
operation CancelRun {
    input := {
        @required
        @httpLabel
        runId: RunId
    }

    output := {
        @required
        run: Run
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ─── Operations: Revisions ──────────────────────────────────────────────────

@readonly
@http(method: "GET", uri: "/ai/runs/{runId}/revisions")
operation ListRunRevisions {
    input := {
        @required
        @httpLabel
        runId: RunId
    }

    output := {
        @required
        revisions: RevisionMap
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/ai/revisions/{revisionId}/apply")
operation ApplyRevision {
    input := {
        @required
        @httpLabel
        revisionId: RevisionId
    }

    output := {
        @required
        revision: Revision
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/ai/revisions/{revisionId}/reject")
operation RejectRevision {
    input := {
        @required
        @httpLabel
        revisionId: RevisionId
    }

    output := {
        @required
        revision: Revision
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ─── Map Types ──────────────────────────────────────────────────────────────

map MessageMap {
    key: MessageId
    value: Message
}

map RevisionMap {
    key: RevisionId
    value: Revision
}

map StepAuditRecordMap {
    key: RunStepId
    value: StepAuditRecord
}

map ConversationMap {
    key: ConversationId
    value: Conversation
}
