$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#UuidLikeMixin
use equaliq#Email
use equaliq#ISODate
use equaliq#StringList
use equaliq#PageLimit
use equaliq#UserId
use equaliq#OrgId
use equaliq#DealId
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Scheduling subsystem — admin surface over Temporal-backed scheduling
/// requests. Reads/writes go to Postgres; force_send / override_slot /
/// cancel fan out as `adminCommand` signals on the request's existing
/// Temporal workflow.

// ─── Identifiers ──────────────────────────────────────────

string SchedulingRequestId with [UuidLikeMixin]
string SchedulingParticipantId with [UuidLikeMixin]
string ProposedSlotId with [UuidLikeMixin]
string SchedulingCalendarEventId with [UuidLikeMixin]
string SchedulingMessageId with [UuidLikeMixin]
string SchedulingAuditLogEntryId with [UuidLikeMixin]
string SchedulingOwnerConfigId with [UuidLikeMixin]
string StakeholderProfileId with [UuidLikeMixin]

// ─── Enums (mirror db-model/scheduling.prisma) ────────────

enum SchedulingRequestStatus {
    NEW = "NEW"
    PROPOSED = "PROPOSED"
    AWAITING_CONFIRMATION = "AWAITING_CONFIRMATION"
    SCHEDULED = "SCHEDULED"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
}

enum SchedulingRequestChannel {
    EMAIL = "EMAIL"
    SMS = "SMS"
    WHATSAPP = "WHATSAPP"
    SCHEDULING_LINK = "SCHEDULING_LINK"
}

enum SchedulingIntentType {
    INTRO_CALL = "INTRO_CALL"
    NEGOTIATION = "NEGOTIATION"
    FOLLOW_UP = "FOLLOW_UP"
    INTERNAL_SYNC = "INTERNAL_SYNC"
    CONTRACT_REVIEW = "CONTRACT_REVIEW"
    UNKNOWN = "UNKNOWN"
}

enum SchedulingOutcomeType {
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
    NO_SHOW = "NO_SHOW"
    RESCHEDULED = "RESCHEDULED"
}

enum SchedulingParticipantRole {
    OWNER = "OWNER"
    INTERNAL_REQUIRED = "INTERNAL_REQUIRED"
    EXTERNAL = "EXTERNAL"
}

enum SlotState {
    PROPOSED = "PROPOSED"
    SELECTED = "SELECTED"
    REJECTED = "REJECTED"
    EXPIRED = "EXPIRED"
    HELD = "HELD"
    RELEASED = "RELEASED"
}

enum SchedulingCalendarProvider {
    GOOGLE = "GOOGLE"
    MICROSOFT = "MICROSOFT"
}

enum SchedulingMessageDirection {
    INBOUND = "INBOUND"
    OUTBOUND = "OUTBOUND"
}

enum SchedulingAuditActor {
    ASSISTANT = "ASSISTANT"
    ADMIN = "ADMIN"
    SYSTEM = "SYSTEM"
}

list SchedulingRequestStatusList {
    member: SchedulingRequestStatus
}

list SchedulingRequestChannelList {
    member: SchedulingRequestChannel
}

// ─── Resource ─────────────────────────────────────────────

/// Admin operations on a single scheduling request. Service-level ops
/// (config, stats, stakeholders) are registered separately under the
/// EqualIQ service since they are not bound to a single requestId.
resource SchedulingResource {
    // Identifier name matches the wire field (`requestId`) used by the
    // existing handlers/frontend, not the DB column (schedulingRequestId).
    identifiers: { requestId: SchedulingRequestId }
    read: GetSchedulingRequest
    list: ListSchedulingRequests
    operations: [
        ForceSchedulingSend
        OverrideSchedulingSlot
        CancelSchedulingRequest
        SetSchedulingOutcome
    ]
}

// ─── Structures ───────────────────────────────────────────

structure SchedulingParticipant {
    @required
    schedulingParticipantId: SchedulingParticipantId

    @required
    requestId: SchedulingRequestId

    @required
    role: SchedulingParticipantRole

    name: String
    email: Email
    phone: String
    timeZone: String

    /// Free-form availability submission captured from inbound messages
    availabilitySubmission: Document

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

list SchedulingParticipantList {
    member: SchedulingParticipant
}

structure ProposedSlot {
    @required
    proposedSlotId: ProposedSlotId

    @required
    requestId: SchedulingRequestId

    @required
    startAt: ISODate

    @required
    endAt: ISODate

    @required
    timeZone: String

    @required
    state: SlotState

    /// Provider-specific hold reference (e.g. Google freebusy hold token)
    holdReference: String

    holdExpiresAt: ISODate

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

list ProposedSlotList {
    member: ProposedSlot
}

structure SchedulingCalendarEvent {
    @required
    schedulingCalendarEventId: SchedulingCalendarEventId

    @required
    requestId: SchedulingRequestId

    @required
    provider: SchedulingCalendarProvider

    @required
    providerEventId: String

    providerEventLink: String

    @required
    startAt: ISODate

    @required
    endAt: ISODate

    /// Attendee list as recorded by the calendar provider
    @required
    attendees: Document

    conferenceLink: String

    @required
    lastSyncedAt: ISODate

    @required
    createdAt: ISODate
}

list SchedulingCalendarEventList {
    member: SchedulingCalendarEvent
}

structure SchedulingMessage {
    @required
    schedulingMessageId: SchedulingMessageId

    @required
    requestId: SchedulingRequestId

    @required
    channel: SchedulingRequestChannel

    @required
    direction: SchedulingMessageDirection

    /// Inbox/thread identifier from the messaging provider
    providerThreadId: String

    senderParticipantId: SchedulingParticipantId

    /// Recipients as JSON; shape depends on channel
    @required
    recipients: Document

    @required
    timestamp: ISODate

    /// AI-extracted entities (slots, attendees, etc.)
    extractedEntities: Document

    body: String
}

list SchedulingMessageList {
    member: SchedulingMessage
}

structure SchedulingAuditLogEntry {
    @required
    schedulingAuditLogEntryId: SchedulingAuditLogEntryId

    @required
    requestId: SchedulingRequestId

    @required
    timestamp: ISODate

    @required
    actor: SchedulingAuditActor

    @required
    actionType: String

    correlationId: String

    payload: Document
}

list SchedulingAuditLogEntryList {
    member: SchedulingAuditLogEntry
}

/// Scheduling request — the durable record paired with one Temporal
/// workflow. The workflow id itself is intentionally not exposed on the
/// wire (internal Temporal detail; admin signals are dispatched
/// server-side).
structure SchedulingRequest {
    @required
    schedulingRequestId: SchedulingRequestId

    @required
    ownerUserId: UserId

    @required
    orgId: OrgId

    dealId: DealId

    @required
    status: SchedulingRequestStatus

    @required
    channel: SchedulingRequestChannel

    intentType: SchedulingIntentType

    title: String

    @required
    desiredDurationMinutes: Integer

    @required
    timeZone: String

    /// Free-form scheduling constraints (working-hours overrides,
    /// blackout windows, etc.) captured from the request source
    constraints: Document

    outcome: SchedulingOutcomeType

    outcomeAt: ISODate

    /// Correlation id when the same scheduling intent appears across
    /// multiple channels (e.g. SMS follow-up to an email thread)
    crossChannelRequestId: String

    deletedAt: ISODate

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate

    // Optional eager-loaded children — populated by GetSchedulingRequest
    Participants: SchedulingParticipantList
    ProposedSlots: ProposedSlotList
    CalendarEvents: SchedulingCalendarEventList
    Messages: SchedulingMessageList
    AuditLog: SchedulingAuditLogEntryList
}

list SchedulingRequestList {
    member: SchedulingRequest
}

/// Slot payload for OverrideSchedulingSlot — admin picks an explicit
/// time outside the AI-proposed set
structure SchedulingSlotInput {
    @required
    startAt: ISODate

    @required
    endAt: ISODate

    /// Defaults to the request's timeZone if omitted
    timeZone: String
}

/// Working-hours block: weekday → list of HH:MM ranges
/// Stored as Document because the day-of-week → range-list shape is
/// owner-defined and varies; coerced in the handler.
structure SchedulingOwnerConfig {
    @required
    schedulingOwnerConfigId: SchedulingOwnerConfigId

    @required
    ownerUserId: UserId

    @required
    orgId: OrgId

    @required
    defaultDurationMinutes: Integer

    @required
    workingHours: Document

    @required
    timeZone: String

    @required
    followUpDelayHours: Integer

    @required
    maxFollowUps: Integer

    /// Owner-defined focus blocks the assistant must avoid
    focusTimeBlocks: Document

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Partial-update payload for /scheduling/config/update — every field
/// optional so admins can patch one knob at a time
structure SchedulingOwnerConfigInput {
    defaultDurationMinutes: Integer
    workingHours: Document
    timeZone: String
    followUpDelayHours: Integer
    maxFollowUps: Integer
    focusTimeBlocks: Document
}

structure StakeholderProfile {
    @required
    stakeholderProfileId: StakeholderProfileId

    @required
    ownerUserId: UserId

    @required
    orgId: OrgId

    email: Email
    phone: String
    name: String
    organizationRole: String
    companyName: String

    /// Owner-curated preferences (preferred channel, contact windows, …)
    preferences: Document

    /// 0.0–1.0 score from communication-pattern analysis
    relationshipStrength: Float

    /// Aggregated communication patterns (cadence, response times, …)
    communicationPatterns: Document

    lastEnrichedAt: ISODate

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

list StakeholderProfileList {
    member: StakeholderProfile
}

/// Fire-and-forget envelope returned by the three admin-signal ops.
/// `success: false` is returned (not thrown) when the request has no
/// active workflow or the Temporal signal fails — admin UIs render the
/// `message` directly.
structure SchedulingSignalResult {
    @required
    success: Boolean

    @required
    message: String
}

/// Aggregate counts for the admin overview
structure SchedulingStats {
    @required
    total: Long

    /// Status → count map (keyed by SchedulingRequestStatus values)
    @required
    byStatus: Document
}

/// Outcome ack — echoes the outcome the admin set
structure SchedulingOutcomeResult {
    @required
    success: Boolean

    /// Echo of the outcome that was persisted; absent on `success: false`
    outcome: SchedulingOutcomeType

    /// Present when success: false (e.g. request not found)
    message: String
}

// ─── Operations ───────────────────────────────────────────

/// List scheduling requests visible to the caller (own + same-org).
/// Cursor pagination on schedulingRequestId, ordered by createdAt desc.
@http(method: "POST", uri: "/scheduling/requests")
operation ListSchedulingRequests {
    input := {
        /// Filter by status (any-of)
        status: SchedulingRequestStatusList

        /// Filter by channel (any-of)
        channel: SchedulingRequestChannelList

        /// Inclusive lower bound on createdAt
        createdAfter: ISODate

        /// Inclusive upper bound on createdAt
        createdBefore: ISODate

        /// Cursor: schedulingRequestId from a prior page's last item
        cursor: SchedulingRequestId

        /// Defaults to 50 when omitted
        limit: PageLimit
    }

    output := {
        @required
        items: SchedulingRequestList

        /// Present when more pages remain
        nextCursor: SchedulingRequestId
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Get a single scheduling request with all child relations eager-loaded
/// (Participants, ProposedSlots, CalendarEvents, Messages, AuditLog).
/// Returns null when the request does not exist or the caller lacks
/// access (no 404 — admin UIs treat both as "not visible").
@http(method: "POST", uri: "/scheduling/request")
operation GetSchedulingRequest {
    input := {
        @required
        requestId: SchedulingRequestId
    }

    output := {
        request: SchedulingRequest
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Force the assistant to send the next outbound message immediately,
/// bypassing follow-up delay timers
@http(method: "POST", uri: "/scheduling/request/send")
operation ForceSchedulingSend {
    input := {
        @required
        requestId: SchedulingRequestId
    }

    output: SchedulingSignalResult

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Override the AI-selected slot with an admin-chosen time. The
/// workflow books a calendar event for the supplied slot.
@http(method: "POST", uri: "/scheduling/request/override")
operation OverrideSchedulingSlot {
    input := {
        @required
        requestId: SchedulingRequestId

        @required
        slot: SchedulingSlotInput
    }

    output: SchedulingSignalResult

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Cancel an in-flight scheduling request
@http(method: "POST", uri: "/scheduling/request/cancel")
operation CancelSchedulingRequest {
    input := {
        @required
        requestId: SchedulingRequestId
    }

    output: SchedulingSignalResult

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Record the post-meeting outcome (completed, no-show, …) and append
/// an audit-log entry
@http(method: "POST", uri: "/scheduling/request/outcome")
operation SetSchedulingOutcome {
    input := {
        @required
        requestId: SchedulingRequestId

        @required
        outcome: SchedulingOutcomeType
    }

    output: SchedulingOutcomeResult

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Get the caller's owner-scoped scheduling config. Returns null when
/// the user has not yet configured one for any org.
@http(method: "POST", uri: "/scheduling/config")
operation GetSchedulingConfig {
    input := {}

    output := {
        config: SchedulingOwnerConfig
    }

    errors: [
        AuthenticationError
        InternalServerError
    ]
}

/// Upsert the caller's owner-scoped scheduling config for an org.
/// Every field on `config` is optional and patched onto the existing
/// row; missing fields fall back to schema defaults on create.
@http(method: "POST", uri: "/scheduling/config/update")
operation UpdateSchedulingConfig {
    input := {
        @required
        orgId: OrgId

        @required
        config: SchedulingOwnerConfigInput
    }

    output := {
        @required
        config: SchedulingOwnerConfig
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Aggregate counts across the caller's visible scheduling requests
/// (own + same-org), excluding soft-deleted rows
@http(method: "POST", uri: "/scheduling/stats")
operation GetSchedulingStats {
    input := {}

    output := {
        @required
        stats: SchedulingStats
    }

    errors: [
        AuthenticationError
        InternalServerError
    ]
}

/// List the caller's stakeholder profiles, optionally filtered by
/// case-insensitive substring on email or company name. Capped at 100,
/// no pagination — admin UI uses the filters to narrow.
@http(method: "POST", uri: "/scheduling/stakeholders")
operation ListStakeholders {
    input := {
        /// Case-insensitive email substring
        email: String

        /// Case-insensitive company-name substring
        companyName: String
    }

    output := {
        @required
        stakeholders: StakeholderProfileList
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}
