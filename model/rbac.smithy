$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#ISODate
use equaliq#Email
use equaliq#StringList
use equaliq#UserId
use equaliq#UserProfile
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// Platform-level roles (system-wide, not organization-scoped)
enum PlatformRole {
    USER = "user"
    DEVELOPER = "developer"
    AUDITOR = "auditor"
}

/// Organization roles
enum OrgRole {
    PRIMARY_OWNER = "primary_owner"
    ADMIN = "admin"
    BILLING_ADMIN = "billing_admin"
    AUDITOR = "auditor"
    MEMBER = "member"
    VIEWER = "viewer"
    CUSTOM = "custom"
}

/// Organization permissions
enum OrgPermission {
    MANAGE_MEMBERS = "manage_members"
    MANAGE_BILLING = "manage_billing"
    MANAGE_SETTINGS = "manage_settings"
    VIEW_ALL_CONTRACTS = "view_all_contracts"
    MANAGE_CONTRACTS = "manage_contracts"
    INVITE_USERS = "invite_users"
    MANAGE_ROLES = "manage_roles"
    VIEW_ANALYTICS = "view_analytics"
    VIEW_AUDIT_LOGS = "view_audit_logs"
}

/// Deal permissions
enum DealPermission {
    VIEW = "VIEW"
    EDIT_DRAFT = "EDIT_DRAFT"
    COMMENT = "COMMENT"
    SIGN = "SIGN"
    SHARE = "SHARE"
    MANAGE = "MANAGE"
}

/// File permissions
enum FilePermission {
    VIEW = "VIEW"
    DOWNLOAD = "DOWNLOAD"
    EDIT = "EDIT"
    DELETE = "DELETE"
    SHARE = "SHARE"
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
    role: OrgRole

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
    inviteId: String

    @required
    orgId: String

    @required
    invitedEmail: Email

    @required
    role: OrgRole

    customRoleId: String
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    invitedBy: UserId
    invitedByProfile: UserProfile

    @required
    status: String

    @required
    createdDate: ISODate

    expiresDate: ISODate
}

/// Deal access control
structure DealAccess {
    @required
    accessId: String

    @required
    dealId: String

    @required
    grantedToOrgId: String

    /// Specific user within org (if omitted, entire org has access)
    grantedToUserId: String

    @required
    grantedBy: String

    @required
    grantedAt: ISODate

    /// Optional expiration
    expiresAt: ISODate

    /// Party role (e.g., "buyer", "seller", "advisor")
    partyRole: String

    @required
    permissions: DealPermissionList

    /// Maximum permissions this party can grant to others
    maxGrantablePermissions: DealPermissionList

    /// Explicit deny (overrides all grants)
    isDeny: Boolean

    /// Revocation tracking
    revokedBy: String
    revokedAt: ISODate
    revocationReason: String

    /// Computed field for active status
    isActive: Boolean
}

/// File access control
structure FileAccess {
    @required
    accessId: String

    @required
    fileId: String

    @required
    grantedToOrgId: String

    /// Specific user within org (if omitted, entire org has access)
    grantedToUserId: String

    @required
    grantedBy: String

    @required
    grantedAt: ISODate

    /// Optional expiration
    expiresAt: ISODate

    @required
    permissions: FilePermissionList

    /// Maximum permissions this party can grant to others
    maxGrantablePermissions: FilePermissionList

    /// Explicit deny (overrides all grants)
    isDeny: Boolean

    /// Revocation tracking
    revokedBy: String
    revokedAt: ISODate
    revocationReason: String

    /// Computed field for active status
    isActive: Boolean
}

// Grant Deal Access
@http(method: "POST", uri: "/deals/{dealId}/access")
operation GrantDealAccess {
    input := {
        @required
        @httpLabel
        dealId: String

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
        maxGrantablePermissions: DealPermissionList

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
        dealId: String

        @required
        accessId: String

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
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "access", pageSize: "limit")
@http(method: "POST", uri: "/deals/access/list")
operation ListDealAccess {
    input := {
        @required
        dealId: String

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
        access: DealAccessList

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
@http(method: "PUT", uri: "/deals/{dealId}/access/{accessId}")
operation UpdateDealAccess {
    input := {
        @required
        @httpLabel
        dealId: String

        @required
        @httpLabel
        accessId: String

        permissions: DealPermissionList
        maxGrantablePermissions: DealPermissionList
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
@http(method: "POST", uri: "/files/{fileId}/access")
operation GrantFileAccess {
    input := {
        @required
        @httpLabel
        fileId: String

        @required
        grantToOrgId: String

        /// Specific user within org (if omitted, entire org has access)
        grantToUserId: String

        @required
        permissions: FilePermissionList

        /// Optional expiration
        expiresAt: ISODate

        /// Permissions they can grant to others
        maxGrantablePermissions: FilePermissionList

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
        fileId: String

        @required
        accessId: String

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
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "access", pageSize: "limit")
@http(method: "POST", uri: "/files/access/list")
operation ListFileAccess {
    input := {
        @required
        fileId: String

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
        access: FileAccessList

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
list DealPermissionList {
    member: DealPermission
}

list FilePermissionList {
    member: FilePermission
}

list DealAccessList {
    member: DealAccess
}

list FileAccessList {
    member: FileAccess
}

list OrgMemberList {
    member: OrgMember
}

list OrgInviteList {
    member: OrgInvite
}