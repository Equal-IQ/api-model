$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#UuidLikeMixin
use equaliq#ISODate
use equaliq#StringList
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Audit log identifier
string AuditLogId with [UuidLikeMixin]

/// Entity types for audit logging
enum AuditEntityType {
    USER = "USER"
    ORGANIZATION = "ORGANIZATION"
    DEAL = "DEAL"
    FILE = "FILE"
    PERMISSION = "PERMISSION"
    INTEGRATION = "INTEGRATION"
    BILLING = "BILLING"
    SYSTEM = "SYSTEM"
}

/// Action types for audit logging
enum AuditAction {
    CREATE = "CREATE"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    VIEW = "VIEW"
    DOWNLOAD = "DOWNLOAD"
    UPLOAD = "UPLOAD"
    SHARE = "SHARE"
    REVOKE = "REVOKE"
    LOGIN = "LOGIN"
    LOGOUT = "LOGOUT"
    EXPORT = "EXPORT"
    IMPORT = "IMPORT"
    SIGN = "SIGN"
    APPROVE = "APPROVE"
    REJECT = "REJECT"
}

/// Data classification levels
enum DataClassification {
    PUBLIC = "PUBLIC"
    INTERNAL = "INTERNAL"
    CONFIDENTIAL = "CONFIDENTIAL"
    RESTRICTED = "RESTRICTED"
}

/// Sensitivity levels
enum SensitivityLevel {
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"
}

/// Audit log resource
resource AuditLogResource {
    identifiers: { logId: AuditLogId }
    read: GetAuditLog
    list: ListAuditLogs
    operations: []
}

/// Audit log entry
structure AuditLog {
    @required
    logId: AuditLogId

    @required
    entityType: AuditEntityType

    @required
    entityId: String

    @required
    action: AuditAction

    @required
    performedBy: String

    @required
    timestamp: ISODate

    /// IP address of the user
    ipAddress: String

    /// User agent string
    userAgent: String

    @required
    success: Boolean

    /// Data classification of the affected resource
    dataClassification: DataClassification

    /// Sensitivity level of the operation
    sensitivityLevel: SensitivityLevel

    /// JSON object with change details
    changeDetails: Document

    /// Error reason if success is false
    errorReason: String

    /// Whether PII was anonymized
    anonymized: Boolean

    /// Pseudonymized user identifier
    pseudonymId: String

    /// Session identifier for correlation
    sessionId: String

    /// Organization context
    orgId: String

    /// Related entity references
    relatedEntities: Document
}

// List Audit Logs
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "logs", pageSize: "limit")
@http(method: "POST", uri: "/audit/list")
operation ListAuditLogs {
    input := {
        // Filters
        entityType: AuditEntityType
        entityId: String
        performedBy: String
        orgId: String
        action: AuditAction
        success: Boolean
        startDate: ISODate
        endDate: ISODate
        minSensitivityLevel: SensitivityLevel
        dataClassification: DataClassification
        sessionId: String

        // Pagination
        nextToken: String
        limit: Integer
    }

    output := {
        @required
        logs: AuditLogList

        /// Token for next page
        nextToken: String

        /// Aggregated statistics
        statistics: AuditStatistics
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
        logId: AuditLogId
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
@http(method: "POST", uri: "/audit/statistics")
operation GetAuditStatistics {
    input := {
        /// Filter by organization
        orgId: String

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
    HOUR = "HOUR"
    DAY = "DAY"
    WEEK = "WEEK"
    MONTH = "MONTH"
}

/// Audit statistics
structure AuditStatistics {
    @required
    totalEvents: Long

    @required
    successfulEvents: Long

    @required
    failedEvents: Long

    /// Breakdown by entity type
    byEntityType: Document

    /// Breakdown by action
    byAction: Document

    /// Most active users
    topUsers: Document

    /// Most accessed entities
    topEntities: Document

    /// Security events count
    securityEvents: Long

    /// Compliance events count
    complianceEvents: Long
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

// Helper list types
list AuditLogList {
    member: AuditLog
}

list TimeSeriesList {
    member: TimeSeriesPoint
}