$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#ISODate
use equaliq#StringList
use equaliq#PageLimit
use equaliq#FileId
use equaliq#DealAccessMap
use equaliq#DealAccess
use equaliq#ThreadMetadataId
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Deal stage lifecycle
enum DealStage {
    drafting = "drafting"
    negotiation = "negotiation"
    signing = "signing"
    delivery = "delivery"
    completed = "completed"
    cancelled = "cancelled"
}

/// Deliverable source (for tracking origin)
enum DeliverableSource {
    inferred = "inferred"
    template = "template"
    imported = "imported"
    manual = "manual"
}

enum DeliverableStatus {
    incomplete = "incomplete"
    in_progress = "in_progress"
    overdure = "overdue"
    complete = "complete"
}

/// How a thread was associated with a deal
enum DealThreadAssociationType {
    manual = "manual"
    ai_suggested = "ai_suggested"
    participant_match = "participant_match"
}

/// Suggestion workflow status for deal-thread associations
enum DealThreadStatus {
    /// Awaiting user review (AI suggestions)
    pending = "pending"
    /// User accepted the association
    accepted = "accepted"
    /// User rejected the association
    rejected = "rejected"
}

string DealId with [UuidLikeMixin]
string DealVersionId with [UuidLikeMixin]
string DealRevisionId with [UuidLikeMixin]
string DeliverableId with [UuidLikeMixin]
string DealAccessId with [UuidLikeMixin]
string DealApprovalId with [UuidLikeMixin]
string DealAnalysisId with [UuidLikeMixin]
string DealThreadId with [UuidLikeMixin]

/// List of deal identifiers
list DealIdList {
    member: DealId
}

/// List of deal version identifiers
list DealVersionIdList {
    member: DealVersionId
}

/// List of file identifiers
list FileIdList {
    member: FileId
}

/// Deal resource with sub-resources for versions, deliverables, and access control
resource DealResource {
    identifiers: { dealId: DealId }
    create: CreateDeal
    read: GetDeal
    update: UpdateDeal
    delete: DeleteDeal
    list: ListDeals
    resources: [DealAccessResource, DealVersionResource, DeliverableResource, DealThreadResource]
}

resource DealVersionResource {
    identifiers: { dealId: DealId, dealVersionId: DealVersionId }
    create: CreateDealVersion
    read: GetDealVersion
    list: ListDealVersions
}

resource DeliverableResource {
    identifiers: { dealId: DealId, deliverableId: DeliverableId }
    create: CreateDeliverable
    update: UpdateDeliverable
    list: ListDeliverables
}

resource DealThreadResource {
    identifiers: { dealId: DealId, dealThreadId: DealThreadId }
    create: CreateDealThread
    update: UpdateDealThread
    delete: DeleteDealThread
    list: ListDealThreads
}

/// Main deal entity
structure Deal {
    @required
    dealId: DealId

    @required
    ownerUserId: UserId

    /// Organization context (nullable for personal deals)
    ownerOrgId: OrgId

    /// Parent deal for hierarchies (master agreements, amendments)
    parentDealId: DealId

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    /// Associated file IDs
    fileIds: FileIdList

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Deal version for tracking changes through stages
structure DealVersion {
    @required
    dealVersionId: DealVersionId

    @required
    dealId: DealId

    @required
    versionNumber: Integer

    @required
    stage: DealStage

    /// Main deal content (name, description, terms, financial details)
    @required
    content: Document

    /// Metadata for extensibility during beta
    metadata: Document

    @required
    createdByUserId: UserId

    /// Approval workflow tracking
    approvedByUserId: UserId

    /// Associated file IDs
    fileIds: FileIdList

    @required
    createdAt: ISODate

    /// When this version was approved
    approvedAt: ISODate
}

/// Deliverable with stage-conditional fields
structure Deliverable {
    @required
    deliverableId: DeliverableId

    @required
    dealVersionId: DealVersionId

    @required
    name: String

    description: String

    /// Source of deliverable (null = manual)
    source: DeliverableSource

    status: DeliverableStatus

    assignedToUserId: UserId

    responsibleOrgId: UserId

    dueDate: ISODate

    completedDate: ISODate

    metadata: Document

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Deal approval for stage transitions
structure DealApproval {
    @required
    dealApprovalId: DealApprovalId

    @required
    dealId: DealId

    dealVersionId: DealVersionId

    @required
    approverUserId: UserId

    /// Approval status as free-form string for flexibility
    @required
    approvalStatus: String

    comments: String

    respondedAt: ISODate

    metadata: Document

    @required
    createdByUserId: UserId

    updatedByUserId: UserId

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure DealRevision {
    @required
    dealRevisionId: DealRevisionId

    @required
    dealId: DealId

    @required
    dealVersionId: DealVersionId

    /// Link to CRDT pipeline or external revision tracking system
    externalRevisionId: String

    /// Description of what changed
    description: String

    /// Additional metadata about the change
    changeMetadata: Document

    @required
    createdByUserId: UserId

    @required
    createdAt: ISODate
}

/// AI-powered deal analysis (clause extraction, risk assessment, etc.)
structure DealAnalysis {
    @required
    dealAnalysisId: DealAnalysisId

    @required
    dealId: DealId

    /// Analysis output (clauses, risks, financial terms, etc.)
    @required
    analysisData: Document

    /// System-generated if null, user-triggered if set
    createdByUserId: UserId

    @required
    createdAt: ISODate
}

// Create Deal
@http(method: "POST", uri: "/deals/create")
operation CreateDeal {
    input := {
        @required
        orgId: OrgId

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
@readonly
@http(method: "POST", uri: "/deals/get")
operation GetDeal {
    input := {
        @required
        dealId: DealId

        /// Include related data
        includeVersions: Boolean
        includeDeliverables: Boolean
        includeAccess: Boolean
    }

    output := {
        @required
        deal: Deal

        versions: DealVersionMap
        deliverables: DeliverableMap
        access: DealAccessMap
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Update Deal
@idempotent
@http(method: "POST", uri: "/deals/update")
operation UpdateDeal {
    input := {
        @required
        dealId: DealId

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
        dealId: DealId

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
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "deals", pageSize: "limit")
@http(method: "POST", uri: "/deals/list")
operation ListDeals {
    input := {
        /// Filter by organization
        orgId: OrgId

        /// Filter by stage
        stage: DealStage

        /// Filter by creator
        createdBy: String

        /// Pagination cursor (encoded dealId)
        nextToken: String

        /// Page size (default 20, max 100)
        limit: PageLimit
    }

    output := {
        @required
        deals: DealMap

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
@http(method: "POST", uri: "/deals/versions/create")
operation CreateDealVersion {
    input := {
        @required
        dealId: DealId

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
@readonly
@http(method: "POST", uri: "/deals/versions/get")
operation GetDealVersion {
    input := {
        @required
        dealId: DealId

        @required
        dealVersionId: DealVersionId

        /// Include deliverables for this version
        includeDeliverables: Boolean
    }

    output := {
        @required
        version: DealVersion

        deliverables: DeliverableMap
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Deal Versions
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "versions", pageSize: "limit")
@http(method: "POST", uri: "/deals/versions/list")
operation ListDealVersions {
    input := {
        @required
        dealId: DealId

        /// Filter by stage
        stage: DealStage

        /// Pagination cursor (encoded versionId)
        nextToken: String

        /// Page size
        limit: PageLimit
    }

    output := {
        @required
        versions: DealVersionMap

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
@http(method: "POST", uri: "/deals/versions/deliverables/create")
operation CreateDeliverable {
    input := {
        @required
        dealId: DealId

        @required
        dealVersionId: DealVersionId

        @required
        description: String

        /// Source of deliverable
        source: DeliverableSource

        /// For committed stages
        dueDate: ISODate
        assignedTo: String
        status: String
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
@http(method: "POST", uri: "/deals/deliverables/update")
operation UpdateDeliverable {
    input := {
        @required
        dealId: DealId

        @required
        deliverableId: DeliverableId

        description: String
        source: DeliverableSource
        dueDate: ISODate
        assignedTo: String
        status: String
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
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "deliverables", pageSize: "limit")
@http(method: "POST", uri: "/deals/deliverables/list")
operation ListDeliverables {
    input := {
        @required
        dealId: DealId

        /// Filter by version
        dealVersionId: DealVersionId

        /// Filter by status
        status: String

        /// Filter by assignee
        assignedTo: String

        /// Pagination cursor (encoded deliverableId)
        nextToken: String

        /// Page size
        limit: PageLimit
    }

    output := {
        @required
        deliverables: DeliverableMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

/// Deal-Thread association
structure DealThread {
    @required
    dealThreadId: DealThreadId

    @required
    dealId: DealId

    @required
    threadMetadataId: ThreadMetadataId

    /// How this thread was associated
    @required
    associationType: DealThreadAssociationType

    /// Suggestion workflow status
    @required
    status: DealThreadStatus

    associatedBy: UserId

    associatedAt: ISODate

    notes: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

// Deal-Thread Junction Operations

/// Associate a thread with a deal
@http(method: "POST", uri: "/deals/threads/create")
operation CreateDealThread {
    input := {
        @required
        dealId: DealId

        @required
        threadMetadataId: ThreadMetadataId

        @required
        associationType: DealThreadAssociationType

        notes: String
    }

    output := {
        @required
        success: Boolean

        @required
        dealThread: DealThread
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

/// Remove thread association from deal
@idempotent
@http(method: "POST", uri: "/deals/threads/delete")
operation DeleteDealThread {
    input := {
        @required
        dealId: DealId

        @required
        dealThreadId: DealThreadId
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

/// Update thread association status (e.g., pending → accepted/rejected)
@idempotent
@http(method: "POST", uri: "/deals/threads/update")
operation UpdateDealThread {
    input := {
        @required
        dealId: DealId

        @required
        dealThreadId: DealThreadId

        /// New status for the association
        status: DealThreadStatus

        /// Updated notes
        notes: String
    }

    output := {
        @required
        success: Boolean

        @required
        dealThread: DealThread
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

/// List threads associated with a deal
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "dealThreads", pageSize: "limit")
@http(method: "POST", uri: "/deals/threads/list")
operation ListDealThreads {
    input := {
        @required
        dealId: DealId

        /// Filter by association type
        associationType: DealThreadAssociationType

        /// Pagination cursor (encoded dealThreadId)
        nextToken: String

        /// Page size
        limit: PageLimit
    }

    output := {
        @required
        dealThreads: DealThreadMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Helper map types
map DealMap {
    key: DealId
    value: Deal
}

map DealVersionMap {
    key: DealVersionId
    value: DealVersion
}

map DeliverableMap {
    key: DeliverableId
    value: Deliverable
}

map DealApprovalMap {
    key: DealApprovalId
    value: DealApproval
}

map DealRevisionMap {
    key: DealRevisionId
    value: DealRevision
}

map DealThreadMap {
    key: DealThreadId
    value: DealThread
}
