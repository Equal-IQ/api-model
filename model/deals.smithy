$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#ISODate
use equaliq#StringList
use equaliq#DealAccess
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Deal stage lifecycle
enum DealStage {
    DRAFTING = "DRAFTING"
    NEGOTIATION = "NEGOTIATION"
    SIGNING = "SIGNING"
    DELIVERY = "DELIVERY"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"
}

/// Deliverable status for committed stages
enum DeliverableStatus {
    PENDING = "PENDING"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    BLOCKED = "BLOCKED"
}

/// Deliverable source (for tracking origin)
enum DeliverableSource {
    INFERRED = "INFERRED"
    TEMPLATE = "TEMPLATE"
    IMPORTED = "IMPORTED"
}

/// Deal approval status
enum DealApprovalStatus {
    PENDING = "PENDING"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    RESCINDED = "RESCINDED"
}

/// Main deal entity
structure Deal {
    @required
    dealId: String

    @required
    orgId: String

    @required
    createdBy: String

    @required
    currentVersionNumber: Integer

    @required
    currentStage: DealStage

    title: String
    description: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Deal version for tracking changes through stages
structure DealVersion {
    @required
    versionId: String

    @required
    dealId: String

    @required
    versionNumber: Integer

    @required
    stage: DealStage

    @required
    createdBy: String

    @required
    createdAt: ISODate

    changeReason: String

    /// JSON metadata for version-specific data
    metadata: Document
}

/// Deliverable with stage-conditional fields
structure Deliverable {
    @required
    deliverableId: String

    @required
    dealVersionId: String

    @required
    description: String

    /// Source of deliverable (null = manual)
    source: DeliverableSource

    /// Required in SIGNING, DELIVERY, COMPLETED stages
    dueDate: ISODate

    /// Required in SIGNING, DELIVERY, COMPLETED stages
    assignedTo: String

    /// Required in SIGNING, DELIVERY, COMPLETED stages
    status: DeliverableStatus

    createdAt: ISODate
    updatedAt: ISODate
}

/// Deal approval for stage transitions
structure DealApproval {
    @required
    approvalId: String

    @required
    dealVersionId: String

    @required
    targetStage: DealStage

    @required
    approverUserId: String

    @required
    status: DealApprovalStatus

    comments: String

    @required
    timestamp: ISODate
}

/// Deal revision metadata (references S3-stored content)
structure DealRevision {
    @required
    revisionId: String

    @required
    dealVersionId: String

    @required
    s3Bucket: String

    @required
    s3Key: String

    @required
    contentType: String

    @required
    sizeBytes: Long

    @required
    createdBy: String

    @required
    createdAt: ISODate

    /// Description of what changed
    description: String
}

// Create Deal
@http(method: "POST", uri: "/deals")
operation CreateDeal {
    input := {
        @required
        orgId: String

        @required
        title: String

        description: String

        /// Optional initial stage, defaults to DRAFTING
        initialStage: DealStage

        /// Optional metadata for the initial version
        metadata: Document
    }

    output := {
        @required
        deal: Deal

        @required
        initialVersion: DealVersion
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Get Deal
@http(method: "POST", uri: "/deals/get")
operation GetDeal {
    input := {
        @required
        dealId: String

        /// Include related data
        includeVersions: Boolean
        includeDeliverables: Boolean
        includeAccess: Boolean
    }

    output := {
        @required
        deal: Deal

        versions: DealVersionList
        deliverables: DeliverableList
        access: DealAccessList
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Update Deal
@idempotent
@http(method: "PUT", uri: "/deals/{dealId}")
operation UpdateDeal {
    input := {
        @required
        @httpLabel
        dealId: String

        title: String
        description: String

        /// Transition to new stage (creates new version)
        newStage: DealStage

        /// Required when changing stage
        changeReason: String

        /// Optional metadata for new version
        metadata: Document
    }

    output := {
        @required
        deal: Deal

        /// New version if stage changed
        newVersion: DealVersion
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Delete Deal
@idempotent
@http(method: "POST", uri: "/deals/delete")
operation DeleteDeal {
    input := {
        @required
        dealId: String

        /// Soft delete by default
        hardDelete: Boolean
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Deals
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "deals", pageSize: "limit")
@http(method: "POST", uri: "/deals/list")
operation ListDeals {
    input := {
        /// Filter by organization
        orgId: String

        /// Filter by stage
        stage: DealStage

        /// Filter by creator
        createdBy: String

        /// Pagination cursor (encoded dealId)
        nextToken: String

        /// Page size (default 20, max 100)
        limit: Integer
    }

    output := {
        @required
        deals: DealList

        /// Token for next page (null if no more results)
        nextToken: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Create Deal Version
@http(method: "POST", uri: "/deals/{dealId}/versions")
operation CreateDealVersion {
    input := {
        @required
        @httpLabel
        dealId: String

        @required
        stage: DealStage

        @required
        changeReason: String

        /// Optional metadata for version
        metadata: Document
    }

    output := {
        @required
        version: DealVersion
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Get Deal Version
@http(method: "POST", uri: "/deals/versions/get")
operation GetDealVersion {
    input := {
        @required
        dealId: String

        @required
        versionId: String

        /// Include deliverables for this version
        includeDeliverables: Boolean
    }

    output := {
        @required
        version: DealVersion

        deliverables: DeliverableList
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Deal Versions
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "versions", pageSize: "limit")
@http(method: "POST", uri: "/deals/versions/list")
operation ListDealVersions {
    input := {
        @required
        dealId: String

        /// Filter by stage
        stage: DealStage

        /// Pagination cursor (encoded versionId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        versions: DealVersionList

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Create Deliverable
@http(method: "POST", uri: "/deals/{dealId}/versions/{versionId}/deliverables")
operation CreateDeliverable {
    input := {
        @required
        @httpLabel
        dealId: String

        @required
        @httpLabel
        versionId: String

        @required
        description: String

        /// Source of deliverable
        source: DeliverableSource

        /// For committed stages
        dueDate: ISODate
        assignedTo: String
        status: DeliverableStatus
    }

    output := {
        @required
        deliverable: Deliverable
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Update Deliverable
@idempotent
@http(method: "PUT", uri: "/deals/{dealId}/deliverables/{deliverableId}")
operation UpdateDeliverable {
    input := {
        @required
        @httpLabel
        dealId: String

        @required
        @httpLabel
        deliverableId: String

        description: String
        source: DeliverableSource
        dueDate: ISODate
        assignedTo: String
        status: DeliverableStatus
    }

    output := {
        @required
        deliverable: Deliverable
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// List Deliverables
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "deliverables", pageSize: "limit")
@http(method: "POST", uri: "/deals/deliverables/list")
operation ListDeliverables {
    input := {
        @required
        dealId: String

        /// Filter by version
        versionId: String

        /// Filter by status
        status: DeliverableStatus

        /// Filter by assignee
        assignedTo: String

        /// Pagination cursor (encoded deliverableId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        deliverables: DeliverableList

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Helper list types
list DealList {
    member: Deal
}

list DealVersionList {
    member: DealVersion
}

list DeliverableList {
    member: Deliverable
}

list DealApprovalList {
    member: DealApproval
}

list DealRevisionList {
    member: DealRevision
}

// Import DealAccessList from rbac.smithy
list DealAccessList {
    member: DealAccess
}