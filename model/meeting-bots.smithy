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

// Transcript structures mirror Recall's `download_url` payload 1:1 so the
// handler can forward parsed JSON without reshaping. Runtime reference:
// meeting-bot/src/types/recall-api.ts (RecallTranscriptContent).
// Names: `TranscriptParticipantEntry` on the parent (Entry suffix distinguishes
// the list member), `TranscriptWord` on the child. `extraData` is `Document`
// (arbitrary JSON, optional). Timestamps are a nested struct: `relative` is
// seconds from the recording start, `absolute` is wall-clock ISO8601.
// CamelCase on the Smithy side; Recall sends snake_case over the wire and
// Smithy marshalling handles the conversion. `participant.id` is `Integer` —
// Recall's participant IDs are small ints scoped to the call.

/// A single participant's contiguous speech segment within a transcript.
/// One of these per speaker per continuous utterance.
structure TranscriptParticipantEntry {
    @required
    participant: TranscriptParticipant

    /// Words spoken by this participant, in order. Each carries its own
    /// start/end timestamps relative to the recording.
    @required
    words: TranscriptWordList
}

list TranscriptParticipantEntryList {
    member: TranscriptParticipantEntry
}

/// Speaker identity attached to a TranscriptParticipantEntry.
/// `id` is Recall's participant identifier (scoped to the call, not globally
/// unique); `name` is the display name Recall captured from the platform.
structure TranscriptParticipant {
    /// Recall-assigned participant ID (small integer, scoped to the call).
    @required
    id: Integer

    @required
    name: String

    /// True when this participant owns / hosts the meeting.
    @required
    isHost: Boolean

    /// Meeting platform the participant joined from (e.g. `zoom`, `meet`, `teams`).
    @required
    platform: String

    /// Free-form platform metadata passed through from Recall. Shape varies per
    /// platform; treat as opaque JSON.
    extraData: Document
}

/// One transcribed word with precise start/end timestamps.
structure TranscriptWord {
    @required
    text: String

    @required
    startTimestamp: TranscriptTimestamp

    @required
    endTimestamp: TranscriptTimestamp
}

list TranscriptWordList {
    member: TranscriptWord
}

/// Timestamp pair: `relative` is seconds from the start of the recording
/// (useful for playback offsets); `absolute` is the wall-clock ISO8601 time.
structure TranscriptTimestamp {
    @required
    relative: Double

    @required
    absolute: ISODate
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

/// Get the parsed transcript for a completed meeting bot.
/// Returned shape mirrors Recall's `download_url` payload: an array of
/// participant entries, each containing the words they spoke with precise
/// timestamps. Wrapped in a response object (rather than a top-level list)
/// because Smithy services can't return top-level arrays cleanly.
@readonly
@http(method: "POST", uri: "/meeting-bot/transcript")
operation GetMeetingTranscript {
    input := {
        @required
        botId: MeetingBotId
    }

    output := {
        /// Parsed transcript. Absent while Recall is still processing, or when
        /// the meeting ended with no captured speech.
        transcript: TranscriptParticipantEntryList
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}
