$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#UuidLikeMixin
use equaliq#ISODate
use equaliq#StringList
use equaliq#PageLimit
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Audit log identifier
string AuditLogId with [UuidLikeMixin]

/// Record types for audit log entries
enum RecordType {
    normal = "normal"
    meta_audit = "meta_audit"
    unknown = "unknown"
    cleanup = "cleanup"
    export = "export"
    system = "system"
}

/// Database operations for audit tracking
enum AuditOperation {
    insert = "insert"
    update = "update"
    delete = "delete"
    access = "access"
    export = "export"
    share = "share"
}

/// Audit log resource
resource AuditLogResource {
    identifiers: { auditLogId: AuditLogId }
    read: GetAuditLog
    list: ListAuditLogs
    operations: []
}

/// Audit log entry for field-level change tracking
structure AuditLog {
    @required
    auditLogId: AuditLogId

    @required
    tableName: String

    @required
    recordType: RecordType

    @required
    operation: AuditOperation

    /// Specific field that changed (for UPDATE operations)
    fieldName: String

    /// Previous value (JSON)
    oldValue: Document

    /// New value (JSON)
    newValue: Document

    @required
    changedBy: String

    @required
    changedAt: ISODate

    /// Additional metadata for extensibility
    metadata: Document
}

// List Audit Logs
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "logs", pageSize: "limit")
@http(method: "POST", uri: "/audit/list")
operation ListAuditLogs {
    input := {
        // Filters
        tableName: String
        recordType: RecordType
        operation: AuditOperation
        changedBy: String
        startDate: ISODate
        endDate: ISODate
        fieldName: String

        // Pagination
        nextToken: String
        limit: PageLimit
    }

    output := {
        @required
        logs: AuditLogMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Get Audit Log
@readonly
@http(method: "POST", uri: "/audit/logs/get")
operation GetAuditLog {
    input := {
        @required
        auditLogId: AuditLogId
    }

    output := {
        @required
        auditLog: AuditLog
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Get Audit Statistics
@readonly
@http(method: "POST", uri: "/audit/statistics")
operation GetAuditStatistics {
    input := {
        /// Filter by table
        tableName: String

        /// Date range for statistics
        @required
        startDate: ISODate

        @required
        endDate: ISODate

        /// Group by period
        groupBy: StatisticGrouping
    }

    output := {
        @required
        statistics: AuditStatistics

        /// Time series data if groupBy is specified
        timeSeries: TimeSeriesList
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Statistic grouping periods
enum StatisticGrouping {
    hour = "hour"
    day = "day"
    week = "week"
    month = "month"
}

/// Audit statistics
structure AuditStatistics {
    @required
    totalEvents: Long

    /// Breakdown by table name
    byTable: Document

    /// Breakdown by operation
    byOperation: Document

    /// Most active users
    topUsers: Document
}

/// Time series data point
structure TimeSeriesPoint {
    @required
    timestamp: ISODate

    @required
    count: Long

    /// Additional metrics
    metrics: Document
}

// Helper types
map AuditLogMap {
    key: AuditLogId
    value: AuditLog
}

list TimeSeriesList {
    member: TimeSeriesPoint
}