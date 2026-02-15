$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#UuidLikeMixin
use equaliq#DealId
use equaliq#FileId
use equaliq#ISODate
use equaliq#Email
use equaliq#StringList
use equaliq#UserId
use equaliq#UserProfile
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Access control identifier
string AccessId with [UuidLikeMixin]

/// Platform-level roles (system-wide, not organization-scoped)
enum PlatformRole {
    user = "user"
    developer = "developer"
    auditor = "auditor"
}

/// Organization permissions
enum OrgPermission {
    manage_members = "manage_members"
    manage_billing = "manage_billing"
    manage_settings = "manage_settings"
    invite_users = "invite_users"
    manage_roles = "manage_roles"
    view_analytics = "view_analytics"
    view_audit_logs = "view_audit_logs"
}

/// Deal permissions
enum DealPermission {
    view_deal = "view_deal"
    edit_deal = "edit_deal"
    delete_deal = "delete_deal"
    manage_access = "manage_access"
    approve_deal = "approve_deal"
    create_version = "create_version"
    view_ai_analysis = "view_ai_analysis"
    view_revision_history = "view_revision_history"
    export_deal = "export_deal"
    manage_deliverables = "manage_deliverables"
    comment_deal = "comment_deal"
    view_financial = "view_financial"
    edit_financial = "edit_financial"
}

/// File permissions
enum FilePermission {
    view_file = "view_file"
    view_all_files = "view_all_files"
    edit_file = "edit_file"
    delete_file = "delete_file"
    share_file = "share_file"
    manage_access = "manage_access"
    comment_file = "comment_file"
    export_file = "export_file"
    rename_file = "rename_file"
}

list OrgPermissionList {
    member: OrgPermission
}

/// Organization member
structure OrgMember {
    @required
    userId: UserId

    @required
    orgEmail: Email

    @required
    role: String

    customRoleId: String
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    joinedDate: ISODate

    userProfile: UserProfile
}

/// Organization invitation
structure OrgInvite {
    @required
    orgInviteId: String

    @required
    orgId: String

    @required
    invitedEmail: Email

    @required
    role: String

    customRoleId: String
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    invitedByUserId: UserId
    invitedByProfile: UserProfile

    @required
    status: InviteStatus

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate

    expiresAt: ISODate

    acceptedAt: ISODate
}

/// Deal access resource (sub-resource of Deal)
resource DealAccessResource {
    identifiers: { dealId: DealId, accessId: AccessId }
    create: GrantDealAccess
    update: UpdateDealAccess
    delete: RevokeDealAccess
    list: ListDealAccess
}

/// Deal access control
structure DealAccess {
    @required
    dealAccessId: AccessId

    @required
    dealId: DealId

    @required
    grantedToOrgId: String

    /// Specific user within org (if omitted, entire org has access)
    grantedToUserId: String

    @required
    grantedByUserId: String

    @required
    grantedAt: ISODate

    /// Optional expiration
    expiresAt: ISODate

    /// Party role (e.g., "buyer", "seller", "advisor")
    partyRole: String

    @required
    permissions: DealPermissionList

    /// Maximum permissions this party can grant to others
    grantablePermissions: DealPermissionList

    /// Explicit deny (overrides all grants)
    isDeny: Boolean

    /// Revocation tracking
    revokedByUserId: String
    revokedAt: ISODate
    revocationReason: String

    /// Additional metadata as JSON
    /// TODO: Post-beta - Consider removing if unused or replace with explicit typed fields
    metadata: Document

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

/// File access resource (sub-resource of File)
resource FileAccessResource {
    identifiers: { fileId: FileId, accessId: AccessId }
    create: GrantFileAccess
    update: UpdateFileAccess
    delete: RevokeFileAccess
    list: ListFileAccess
}

/// File access control
structure FileAccess {
    @required
    fileAccessId: AccessId

    @required
    fileId: FileId

    @required
    grantedToOrgId: String

    /// Specific user within org (if omitted, entire org has access)
    grantedToUserId: String

    @required
    grantedByUserId: String

    @required
    grantedAt: ISODate

    /// Optional expiration
    expiresAt: ISODate

    @required
    permissions: FilePermissionList

    /// Maximum permissions this party can grant to others
    grantablePermissions: FilePermissionList

    /// Explicit deny (overrides all grants)
    isDeny: Boolean

    /// Revocation tracking
    revokedByUserId: String
    revokedAt: ISODate
    revocationReason: String

    /// Additional metadata as JSON
    /// TODO: Post-beta - Consider removing if unused or replace with explicit typed fields
    metadata: Document

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
}

// Grant Deal Access
@http(method: "POST", uri: "/deals/access/grant")
operation GrantDealAccess {
    input := {
        @required
        dealId: DealId

        @required
        grantToOrgId: String

        /// Specific user within org (if omitted, entire org has access)
        grantToUserId: String

        @required
        permissions: DealPermissionList

        /// Optional party role
        partyRole: String

        /// Optional expiration
        expiresAt: ISODate

        /// Permissions they can grant to others
        grantablePermissions: DealPermissionList

        /// Explicit deny
        isDeny: Boolean
    }

    output := {
        @required
        access: DealAccess
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Revoke Deal Access
@idempotent
@http(method: "POST", uri: "/deals/access/revoke")
operation RevokeDealAccess {
    input := {
        @required
        dealId: DealId

        @required
        accessId: AccessId

        @required
        reason: String
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Deal Access
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "access", pageSize: "limit")
@http(method: "POST", uri: "/deals/access/list")
operation ListDealAccess {
    input := {
        @required
        dealId: DealId

        /// Filter by organization
        orgId: String

        /// Include revoked access
        includeRevoked: Boolean

        /// Include expired access
        includeExpired: Boolean

        /// Pagination cursor (encoded accessId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        access: DealAccessMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Update Deal Access
@idempotent
@http(method: "POST", uri: "/deals/access/update")
operation UpdateDealAccess {
    input := {
        @required
        dealId: DealId

        @required
        accessId: AccessId

        permissions: DealPermissionList
        grantablePermissions: DealPermissionList
        partyRole: String
        expiresAt: ISODate
        isDeny: Boolean
    }

    output := {
        @required
        access: DealAccess
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Grant File Access
@http(method: "POST", uri: "/files/access/grant")
operation GrantFileAccess {
    input := {
        @required
        fileId: FileId

        @required
        grantToOrgId: String

        /// Specific user within org (if omitted, entire org has access)
        grantToUserId: String

        @required
        permissions: FilePermissionList

        /// Optional expiration
        expiresAt: ISODate

        /// Permissions they can grant to others
        grantablePermissions: FilePermissionList

        /// Explicit deny
        isDeny: Boolean
    }

    output := {
        @required
        access: FileAccess
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Revoke File Access
@idempotent
@http(method: "POST", uri: "/files/access/revoke")
operation RevokeFileAccess {
    input := {
        @required
        fileId: FileId

        @required
        accessId: AccessId

        @required
        reason: String
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List File Access
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "access", pageSize: "limit")
@http(method: "POST", uri: "/files/access/list")
operation ListFileAccess {
    input := {
        @required
        fileId: FileId

        /// Filter by organization
        orgId: String

        /// Include revoked access
        includeRevoked: Boolean

        /// Include expired access
        includeExpired: Boolean

        /// Pagination cursor (encoded accessId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        access: FileAccessMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Update File Access
@idempotent
@http(method: "POST", uri: "/files/access/update")
operation UpdateFileAccess {
    input := {
        @required
        fileId: FileId

        @required
        accessId: AccessId

        permissions: FilePermissionList
        grantablePermissions: FilePermissionList
        expiresAt: ISODate
        isDeny: Boolean
    }

    output := {
        @required
        access: FileAccess
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Helper list types
list DealPermissionList {
    member: DealPermission
}

list FilePermissionList {
    member: FilePermission
}

map DealAccessMap {
    key: AccessId
    value: DealAccess
}

map FileAccessMap {
    key: AccessId
    value: FileAccess
}

list OrgMemberList {
    member: OrgMember
}

list OrgInviteList {
    member: OrgInvite
}