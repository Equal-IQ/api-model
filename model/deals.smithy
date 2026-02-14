$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#ISODate
use equaliq#StringList
use equaliq#DealAccessMap
use equaliq#DealAccess
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

string DealId with [UuidLikeMixin]

/// Deal resource with sub-resources for versions, deliverables, and access control
resource DealResource {
    identifiers: { dealId: DealId }
    create: CreateDeal
    read: GetDeal
    update: UpdateDeal
    delete: DeleteDeal
    list: ListDeals
    resources: [DealAccessResource]
    operations: [
        CreateDealVersion
        GetDealVersion
        ListDealVersions
        CreateDeliverable
        UpdateDeliverable
        ListDeliverables
    ]
}

/// Main deal entity
structure Deal {
    @required
    dealId: DealId

    @required
    ownerUserId: String

    /// Organization context (nullable for personal deals)
    ownerOrgId: String

    /// Parent deal for hierarchies (master agreements, amendments)
    parentDealId: String

    @required
    createdByUserId: String

    updatedByUserId: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Deal version for tracking changes through stages
structure DealVersion {
    @required
    dealVersionId: String

    @required
    dealId: String

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
    createdByUserId: String

    /// Approval workflow tracking
    approvedByUserId: String

    @required
    createdAt: ISODate

    /// When this version was approved
    approvedAt: ISODate
}

/// Deliverable with stage-conditional fields
structure Deliverable {
    @required
    deliverableId: String

    @required
    dealVersionId: String

    @required
    name: String

    description: String

    /// Source of deliverable (null = manual)
    source: DeliverableSource

    /// Status as free-form string for flexibility
    status: String

    assignedToUserId: String

    responsibleOrgId: String

    dueDate: ISODate

    completedDate: ISODate

    metadata: Document

    @required
    createdByUserId: String

    updatedByUserId: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// Deal approval for stage transitions
structure DealApproval {
    @required
    dealApprovalId: String

    @required
    dealId: String

    dealVersionId: String

    @required
    approverUserId: String

    /// Approval status as free-form string for flexibility
    @required
    approvalStatus: String

    comments: String

    respondedAt: ISODate

    metadata: Document

    @required
    createdByUserId: String

    updatedByUserId: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

structure DealRevision {
    @required
    dealRevisionId: String

    @required
    dealId: String

    @required
    dealVersionId: String

    /// Link to CRDT pipeline or external revision tracking system
    externalRevisionId: String

    /// Description of what changed
    description: String

    /// Additional metadata about the change
    changeMetadata: Document

    @required
    createdByUserId: String

    @required
    createdAt: ISODate
}

/// AI-powered deal analysis (clause extraction, risk assessment, etc.)
structure DealAnalysis {
    @required
    dealAnalysisId: String

    @required
    dealId: String

    /// Analysis output (clauses, risks, financial terms, etc.)
    @required
    analysisData: Document

    /// System-generated if null, user-triggered if set
    createdByUserId: String

    @required
    createdAt: ISODate
}

// Create Deal
@http(method: "POST", uri: "/deals/create")
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
        versionId: String

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
        limit: Integer
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
        versionId: String

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
        deliverableId: String

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
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "deliverables", pageSize: "limit")
@http(method: "POST", uri: "/deals/deliverables/list")
operation ListDeliverables {
    input := {
        @required
        dealId: DealId

        /// Filter by version
        versionId: String

        /// Filter by status
        status: String

        /// Filter by assignee
        assignedTo: String

        /// Pagination cursor (encoded deliverableId)
        nextToken: String

        /// Page size
        limit: Integer
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

// Helper map types
map DealMap {
    key: DealId
    value: Deal
}

map DealVersionMap {
    key: String  // dealVersionId
    value: DealVersion
}

map DeliverableMap {
    key: String  // deliverableId
    value: Deliverable
}

map DealApprovalMap {
    key: String  // dealApprovalId
    value: DealApproval
}

map DealRevisionMap {
    key: String  // dealRevisionId
    value: DealRevision
}
