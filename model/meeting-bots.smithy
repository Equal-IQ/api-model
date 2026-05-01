$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#Url
use equaliq#ISODate
use equaliq#PageLimit
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError


// Identifiers
/// Recall.ai bot identifier. Externally assigned by Recall; we treat it as an
/// opaque UUID-shaped string.
string MeetingBotId with [UuidLikeMixin]

// Meeting bot resource
/// Recall.ai meeting bot resource.
/// Bots join scheduled video meetings (Zoom, Meet, Teams) to capture
/// recordings and transcripts for later analysis.
resource MeetingBotResource {
    identifiers: { botId: MeetingBotId }
    create: CreateMeetingBot
    read: GetMeetingBotStatus
    list: ListMeetingBots
    operations: [
        CancelMeetingBot
        LeaveMeetingBot
        GetMeetingRecording
        GetMeetingTranscript
    ]
}

// MeetingBotStatus is intentionally a raw String rather than a Smithy enum: Recall
// owns the status taxonomy and adds new states without a contract bump. Clients
// branch on well-known values (`joining_call`, `in_call_recording`, `done`,
// `fatal`) and treat unknown values as transient. The `@documentation` string
// below is repeated verbatim on every field that exposes this type because Smithy
// does not share `@documentation` across shape references.
@documentation("""
Recall.ai bot lifecycle status. Raw string from the Recall API — we intentionally
do not model this as an enum because Recall owns the taxonomy and introduces new
states without a contract bump. Callers should branch on well-known values
(`joining_call`, `in_call_recording`, `done`, `fatal`) and treat unknown values
as transient.""")
string MeetingBotStatus

/// Summary of a meeting bot for list operations.
/// Subset of GetMeetingBotStatus output — does NOT include recordingUrl or
/// transcriptAvailable (those require per-bot Recall fetches that would blow
/// up list latency).
structure MeetingBotSummary {
    @required
    botId: MeetingBotId

    /// Meeting platform URL the bot joined (Zoom / Meet / Teams link).
    @required
    meetingUrl: Url

    @documentation("""
Recall.ai bot lifecycle status. Raw string from the Recall API — we intentionally
do not model this as an enum because Recall owns the taxonomy and introduces new
states without a contract bump. Callers should branch on well-known values
(`joining_call`, `in_call_recording`, `done`, `fatal`) and treat unknown values
as transient.""")
    @required
    status: MeetingBotStatus

    /// Display name the bot uses when it joins the call.
    botName: String

    /// Scheduled join time. Absent when the bot was dispatched immediately.
    joinAt: ISODate

    @required
    createdAt: ISODate
}

list MeetingBotSummaryList {
    member: MeetingBotSummary
}

// Transcript processing lifecycle — owned by contract-analysis Step Functions.
// The raw Recall JSON is an internal workflow detail (persisted to
// MeetingTranscript.rawContent as a source-of-truth mirror); the public
// contract surfaces only the FORMATTED transcript + summary that downstream
// clients actually consume. Runtime reference for both types:
// contract-analysis/src/types/transcription.types.ts (FormattedTranscript,
// MeetingSummary).
//
// Status taxonomy: pending (no work yet) → raw_ready (Recall JSON fetched)
// → formatting → formatted (formattedContent column populated) → summarizing
// → complete (summary column populated) → failed (terminal; see processingError).
// Modeled as an enum here because the taxonomy is owned by our own workflow,
// not a vendor (contrast with MeetingBotStatus).

/// Processing lifecycle of a meeting transcript through the
/// contract-analysis Step Functions workflow.
enum TranscriptProcessingStatus {
    PENDING = "pending"
    RAW_READY = "raw_ready"
    FORMATTING = "formatting"
    FORMATTED = "formatted"
    SUMMARIZING = "summarizing"
    COMPLETE = "complete"
    FAILED = "failed"
}

list StringList {
    member: String
}

/// Compact formatted transcript produced by the contract-analysis
/// transcriptFormattingHandler. `text` is the full transcript rendered as
/// `[HH:MM:SS] Name: utterance\n`; `metadata` summarizes participants and
/// timing. Returned only when processingStatus = `complete`.
structure FormattedTranscript {
    /// Compact transcript text, one line per contiguous utterance.
    /// Format: `[HH:MM:SS] Name: text\n`.
    @required
    text: String

    @required
    metadata: FormattedTranscriptMetadata
}

/// Summary header on a FormattedTranscript. Participant list is flattened
/// from the raw Recall data; timestamps are wall-clock and may be null when
/// Recall did not attach absolute times to the recording.
structure FormattedTranscriptMetadata {
    /// Distinct speakers counted in the transcript.
    @required
    totalParticipants: Integer

    @required
    participants: FormattedTranscriptParticipantList

    /// Recording duration in seconds.
    @required
    duration: Integer

    /// Wall-clock recording start. Null when Recall did not attach an absolute
    /// timestamp to the first word.
    startTime: ISODate

    /// Wall-clock recording end. Null when Recall did not attach an absolute
    /// timestamp to the last word.
    endTime: ISODate
}

list FormattedTranscriptParticipantList {
    member: FormattedTranscriptParticipant
}

/// Flattened speaker identity on a FormattedTranscript. `id` is Recall's
/// per-call participant ID; `name` may be null when Recall did not capture
/// a display name from the meeting platform.
structure FormattedTranscriptParticipant {
    /// Recall-assigned participant ID (small integer, scoped to the call).
    @required
    id: Integer

    /// Display name Recall captured from the platform. Null when absent.
    name: String

    /// True when this participant owns / hosts the meeting.
    @required
    isHost: Boolean
}

/// LLM-generated meeting summary produced by the contract-analysis
/// transcriptSummaryHandler. Every field is required; `summary` is the
/// narrative, the list fields are extracted structured data. Returned only
/// when processingStatus = `complete`.
structure MeetingSummary {
    /// Short title the LLM generated for the meeting.
    @required
    title: String

    /// Narrative overview of the meeting.
    @required
    summary: String

    /// Main discussion points. May be empty.
    @required
    keyPoints: StringList

    /// Action items the LLM extracted. May be empty.
    @required
    actionItems: ActionItemList

    /// Key decisions made during the meeting. May be empty.
    @required
    decisions: StringList

    /// Topics discussed. May be empty.
    @required
    topics: StringList
}

list ActionItemList {
    member: ActionItem
}

/// A single action item extracted from the meeting. `assignee` is null when
/// the LLM could not attribute ownership; `mentioned` is true when the item
/// was explicitly stated, false when inferred from context.
structure ActionItem {
    @required
    description: String

    /// Person the action was assigned to. Null when unattributed.
    assignee: String

    /// True when the action was explicitly mentioned; false when inferred.
    @required
    mentioned: Boolean
}

// Operations

/// Dispatch a Recall.ai bot to a scheduled meeting.
/// The bot joins at `joinAt` (or immediately if omitted), records the meeting,
/// and posts webhook events back as it progresses through the Recall lifecycle.
@http(method: "POST", uri: "/meeting-bot/create")
operation CreateMeetingBot {
    input := {
        /// Video meeting URL the bot should join (Zoom / Meet / Teams).
        @required
        meetingUrl: Url

        /// Display name the bot uses when it appears in the participant list.
        /// Defaults to a configured fallback when omitted.
        @length(max: 100)
        botName: String

        /// Scheduled join time. Must be within 10 minutes of a real meeting
        /// start — Recall rejects bots scheduled too far out. Enforcement lives
        /// in the RecallClient (not Smithy-expressible).
        /// Omit for immediate dispatch.
        joinAt: ISODate
    }

    output := {
        @required
        botId: MeetingBotId

        @documentation("""
Recall.ai bot lifecycle status. Raw string from the Recall API — we intentionally
do not model this as an enum because Recall owns the taxonomy and introduces new
states without a contract bump. Callers should branch on well-known values
(`joining_call`, `in_call_recording`, `done`, `fatal`) and treat unknown values
as transient.""")
        @required
        status: MeetingBotStatus
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Fetch current status of a dispatched bot, plus (when available) the
/// recording URL and a flag indicating whether the transcript download has
/// landed. Both `recordingUrl` and `transcriptAvailable` are optional because
/// they are populated only after Recall finishes post-processing.
@readonly
@http(method: "POST", uri: "/meeting-bot/status")
operation GetMeetingBotStatus {
    input := {
        @required
        botId: MeetingBotId
    }

    output := {
        @documentation("""
Recall.ai bot lifecycle status. Raw string from the Recall API — we intentionally
do not model this as an enum because Recall owns the taxonomy and introduces new
states without a contract bump. Callers should branch on well-known values
(`joining_call`, `in_call_recording`, `done`, `fatal`) and treat unknown values
as transient.""")
        @required
        status: MeetingBotStatus

        /// Presigned URL to the raw video/audio recording, if Recall has
        /// finished upload. Clients should treat absence as "not ready yet."
        recordingUrl: Url

        /// True when the transcript download has completed and
        /// `GetMeetingTranscript` will return content.
        transcriptAvailable: Boolean
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

/// List bots created by the authenticated user, newest first.
/// Bounded by `limit` (1..100). Not paginated — the handler returns a single
/// page keyed off Postgres `MeetingBot` rows for the caller, with Recall
/// refreshing transient rows lazily in the same query. Add pagination when a
/// consumer actually needs it.
@readonly
@http(method: "POST", uri: "/meeting-bot/list")
operation ListMeetingBots {
    input := {
        /// Filter by Recall status string. Same taxonomy as the `status` field
        /// on `MeetingBotSummary` — caller-chosen, not validated against an enum.
        status: String

        /// Result limit. Default and max enforced by `PageLimit` (1..100).
        limit: PageLimit
    }

    output := {
        @required
        bots: MeetingBotSummaryList
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Cancel a scheduled bot before it joins the call.
/// Idempotent: cancelling an already-cancelled bot succeeds.
/// For bots already in an active call, use `LeaveMeetingBot` instead.
@idempotent
@http(method: "POST", uri: "/meeting-bot/cancel")
operation CancelMeetingBot {
    input := {
        @required
        botId: MeetingBotId
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

/// Force a bot currently in an active call to leave.
/// NOT idempotent — the underlying `leaveCall` handler throws when the bot is
/// not in an active call, so a second invocation after success returns an error
/// rather than a no-op. For scheduled bots that haven't joined yet, use
/// `CancelMeetingBot`.
@http(method: "POST", uri: "/meeting-bot/leave-call")
operation LeaveMeetingBot {
    input := {
        @required
        botId: MeetingBotId
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

/// Get the recording URL for a completed meeting bot.
/// Returns null while Recall is still processing the upload; poll
/// `GetMeetingBotStatus` for readiness rather than tight-looping here.
@readonly
@http(method: "POST", uri: "/meeting-bot/recording")
operation GetMeetingRecording {
    input := {
        @required
        botId: MeetingBotId
    }

    output := {
        /// Presigned recording URL. Absent while upload is still processing.
        recordingUrl: Url
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

/// Fetch the processed transcript + LLM summary for a meeting bot.
///
/// Surfaces the state of the contract-analysis Step Functions pipeline:
///   - `processingStatus` always reflects the latest workflow stage (see
///     `TranscriptProcessingStatus` for the lifecycle).
///   - `transcript` and `summary` are populated ONLY when
///     `processingStatus = complete`. Both return null for every other
///     status, including `failed`.
///   - `processingError` carries a human-readable failure detail when
///     `processingStatus = failed`. Absent / null otherwise.
///
/// The raw Recall JSON is intentionally NOT exposed — it's a workflow-internal
/// source-of-truth mirror. Clients poll `GetMeetingBotStatus.transcriptAvailable`
/// for bot-level readiness, then poll this endpoint for processing readiness.
@readonly
@http(method: "POST", uri: "/meeting-bot/transcript")
operation GetMeetingTranscript {
    input := {
        @required
        botId: MeetingBotId
    }

    output := {
        /// Current stage of the transcript processing pipeline. Clients
        /// should treat any status other than `complete` as "not yet ready."
        @required
        processingStatus: TranscriptProcessingStatus

        /// Human-readable failure detail. Populated only when
        /// `processingStatus = failed`.
        processingError: String

        /// Formatted transcript + metadata. Populated only when
        /// `processingStatus = complete`; null for every other status.
        transcript: FormattedTranscript

        /// LLM-generated meeting summary. Populated only when
        /// `processingStatus = complete`; null for every other status.
        summary: MeetingSummary
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}
