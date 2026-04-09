/**
 * EA Agent shared types — Temporal signal, command, and query contracts.
 * Shared between equal-iq-ea worker and cdk webhook/admin Lambdas.
 *
 * DO NOT add to smithy-build.json — this file is maintained manually.
 */

// ─── Channel & Status Enums (mirrors of Prisma enums for cross-repo use) ──

export type SchedulingRequestChannel = "EMAIL" | "SMS" | "WHATSAPP" | "SCHEDULING_LINK";
export type SchedulingCalendarProvider = "GOOGLE" | "MICROSOFT";
export type SchedulingMessageDirection = "INBOUND" | "OUTBOUND";
export type SchedulingRequestStatus =
  | "NEW"
  | "PROPOSED"
  | "AWAITING_CONFIRMATION"
  | "SCHEDULED"
  | "FAILED"
  | "CANCELLED";
export type SchedulingIntentType =
  | "INTRO_CALL"
  | "NEGOTIATION"
  | "FOLLOW_UP"
  | "INTERNAL_SYNC"
  | "CONTRACT_REVIEW"
  | "UNKNOWN";

export type ResponseType =
  | "proposal"
  | "follow_up"
  | "re_proposal"
  | "confirmation"
  | "reschedule"
  | "briefing"
  | "notification"
  | "error_calendar_unavailable";

// ─── Inbound Signals (webhook Lambda → Temporal workflow) ─────────────────

export type Signal =
  | { type: "inbound_message"; channel: SchedulingRequestChannel; raw: NormalizedMessage }
  | { type: "calendar_webhook"; provider: SchedulingCalendarProvider; event: CalendarWebhookPayload };

export interface NormalizedMessage {
  id: string;
  channel: SchedulingRequestChannel;
  direction: SchedulingMessageDirection;
  senderEmail?: string;
  senderPhone?: string;
  senderName?: string;
  recipients: Array<{ email?: string; phone?: string; name?: string }>;
  subject?: string;
  bodyText: string; // plain text, max 4000 chars, no raw HTML
  threadId?: string; // provider thread ID for continuity
  providerMessageId: string;
  timestamp: Date;
  rawMetadata: Record<string, unknown>;
}

export interface CalendarWebhookPayload {
  eventType: string;
  accountId: string;
  eventId: string;
  data: Record<string, unknown>;
}

export interface SendMessageRequest {
  channel: SchedulingRequestChannel;
  from: string; // agent identity (ari@equal-iq.com or per-customer)
  to: string[];
  subject?: string;
  body: string;
  threadId?: string;
  requestId: string;
}

// ─── Admin Commands (web client Lambda → Temporal signal) ─────────────────

export type AdminCommand =
  | { action: "force_send"; requestId: string; adminUserId: string }
  | { action: "override_slot"; requestId: string; slot: SlotSelection; adminUserId: string }
  | { action: "cancel"; requestId: string; adminUserId: string }
  | { action: "reassign"; requestId: string; newOwnerUserId: string; adminUserId: string };

// ─── Admin Queries (web client Lambda → Temporal query or DB) ─────────────

export type AdminQuery =
  | { action: "list_requests"; filters: RequestFilters; pagination: Pagination }
  | { action: "get_request_detail"; requestId: string }
  | { action: "get_owner_config"; ownerUserId: string }
  | { action: "get_dashboard_stats"; ownerUserId?: string }
  | { action: "get_stakeholder_profiles"; filters: StakeholderFilters };

// ─── Shared Value Types ───────────────────────────────────────────────────

export interface SlotSelection {
  slotId: string;
  startAt: string; // ISO date
  endAt: string; // ISO date
}

export interface TimeSlot {
  startAt: string; // ISO date
  endAt: string; // ISO date
  timeZone: string;
}

export interface TimeRange {
  earliest: string; // ISO date
  latest: string; // ISO date
}

export interface RankedSlot {
  slot: TimeSlot;
  score: number; // 0.0 - 1.0
  reasons: string[];
  timezoneLabels: Record<string, string>; // participantTz → display label
}

export interface ExtractedEntities {
  attendees: Array<{
    name?: string;
    email?: string;
    phone?: string;
    role?: "owner" | "internal" | "external";
  }>;
  duration?: {
    minutes: number;
    source: "explicit" | "inferred" | "default";
  };
  timeWindow?: {
    earliest?: string; // ISO date
    latest?: string; // ISO date
    description?: string; // raw text: "next week", "sometime in March"
  };
  timezone?: {
    iana: string; // "America/New_York"
    source: "explicit" | "inferred" | "profile";
  };
  preferences?: string[]; // raw text: ["morning preferred", "avoid Fridays"]
}

// ─── Filter & Pagination Types ────────────────────────────────────────────

export interface RequestFilters {
  ownerUserId?: string;
  orgId?: string;
  status?: SchedulingRequestStatus[];
  channel?: SchedulingRequestChannel[];
  createdAfter?: string; // ISO date
  createdBefore?: string; // ISO date
}

export interface StakeholderFilters {
  ownerUserId?: string;
  orgId?: string;
  email?: string;
  companyName?: string;
}

export interface Pagination {
  cursor?: string;
  limit?: number; // default 50
}

export interface PaginatedResult<T> {
  items: T[];
  nextCursor?: string;
  totalCount?: number;
}

// ─── Workflow Status (Temporal query response) ────────────────────────────

export interface WorkflowStatus {
  phase: string;
  requestId: string;
}
