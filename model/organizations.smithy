$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#UserId
use equaliq#UserProfile
use equaliq#Url
use equaliq#Email
use equaliq#ISODate
use equaliq#StringList
use equaliq#EmailList
use equaliq#HexColor
use equaliq#PresignedPostData

// Import RBAC structures from rbac.smithy
// Note: These are now defined in rbac.smithy
// - OrgRole enum
// - OrgPermission enum
// - OrgPermissionList
// - OrgMember structure
// - OrgInvite structure

// Org structures and operations

string OrgId with [UuidLikeMixin]
string InviteId with [UuidLikeMixin]
string OrgCustomRoleId with [UuidLikeMixin]

enum InviteStatus {
    pending = "pending"
    accepted = "accepted"
    declined = "declined"
    expired = "expired"
}

map OrgMemberMap {
    key: UserId
    value: OrgMember
}

map OrgInviteMap {
    key: InviteId
    value: OrgInvite
}

map OrgCustomRoleMap {
    key: OrgCustomRoleId
    value: OrgCustomRole
}

structure Org {
    @required
    orgId: OrgId

    @required
    name: String

    @required
    type: String

    @required
    primaryOwnerId: UserId

    description: String
    website: Url
    logoUrl: Url

    billingEmail: Email

    /// Additional metadata (UI preferences, etc.)
    /// TODO: Post-beta - Consider removing if unused or replace with explicit typed fields
    metadata: Document

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate

    // Computed/context fields
    memberCount: Integer
    userRole: OrgRole
    dealCount: Integer
    inviteCount: Integer
    roleCount: Integer
}

structure OrgCustomRole {
    @required
    customRoleId: OrgCustomRoleId

    @required
    orgId: OrgId

    @required
    name: String

    description: String

    @required
    permissions: OrgPermissionList

    @required
    createdDate: ISODate

    @required
    createdBy: UserId
    
    // Frontend-specific field
    memberCount: Integer
}

structure OrgTheme {
    primaryColor: HexColor
    secondaryColor: HexColor
    accentColor: HexColor
}

// ==================== SMITHY RESOURCES ====================

resource Organization {
    identifiers: { orgId: OrgId }
    create: CreateOrg
    read: GetOrg
    update: UpdateOrg
    delete: DeleteOrg
    list: ListUserOrganizations
    resources: [OrganizationMember, OrganizationInvite, OrganizationCustomRole]
    operations: [
        UploadOrgPicture
        GetOrgPicture
        UpdateOrgTheme
        GetOrgTheme
        TransferOrgOwnership
    ]
}

resource OrganizationMember {
    identifiers: { orgId: OrgId, userId: UserId }
    list: ListOrgMembers
    update: UpdateOrgMember
    delete: RemoveOrgMember
}

resource OrganizationInvite {
    identifiers: { orgId: OrgId, inviteId: InviteId }
    create: CreateOrgInvite
    list: ListOrgInvites
    delete: CancelOrgInvite
    operations: [
        ResendOrgInvite
        AcceptOrgInvite
        DeclineOrgInvite
    ]
}

resource OrganizationCustomRole {
    identifiers: { orgId: OrgId, customRoleId: OrgCustomRoleId }
    create: CreateOrgCustomRole
    list: ListOrgCustomRoles
    update: UpdateOrgCustomRole
    delete: DeleteOrgCustomRole
}

// ==================== ORGANIZATION MANAGEMENT APIs ====================

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "organizations", pageSize: "limit")
@http(method: "POST", uri: "/orgs/listUserOrganizations")
operation ListUserOrganizations {
    input := {
        /// Pagination cursor (encoded orgId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        organizations: OrgMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        InternalServerError
    ]
}

map OrgMap {
    key: OrgId
    value: Org
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@http(method: "POST", uri: "/orgs/get")
operation GetOrg {
    input := {
        @required
        orgId: OrgId
    }

    output := {
        @required
        org: Org
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/create")
operation CreateOrg {
    input := {
        @required
        name: String

        @required
        type: String

        description: String
        website: Url

        @required
        billingEmail: Email
    }

    output := {
        @required
        org: Org
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/orgs/update")
operation UpdateOrg {
    input := {
        @required
        orgId: OrgId

        name: String
        description: String
        website: Url
        billingEmail: Email
    }

    output := {
        @required
        org: Org
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/delete")
operation DeleteOrg {
    input := {
        @required
        orgId: OrgId
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ==================== MEMBER MANAGEMENT APIs ====================

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "members", pageSize: "limit")
@http(method: "POST", uri: "/orgs/members/list")
operation ListOrgMembers {
    input := {
        @required
        orgId: OrgId

        /// Filter by role
        role: OrgRole

        /// Include inactive members
        includeInactive: Boolean

        /// Pagination cursor (encoded userId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        members: OrgMemberMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/orgs/updateMember")
operation UpdateOrgMember {
    input := {
        @required
        orgId: OrgId

        @required
        userId: UserId

        role: OrgRole
        customRoleId: OrgCustomRoleId
        orgEmail: Email
    }

    output := {
        @required
        member: OrgMember
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/removeMember")
operation RemoveOrgMember {
    input := {
        @required
        orgId: OrgId

        @required
        userId: UserId
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/orgs/transferOwnership")
operation TransferOrgOwnership {
    input := {
        @required
        orgId: OrgId

        @required
        newOwnerId: UserId
    }

    output := {
        @required
        org: Org
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ==================== ROLE MANAGEMENT APIs ====================

@idempotent
@http(method: "POST", uri: "/orgs/roles/create")
operation CreateOrgCustomRole {
    input := {
        @required
        orgId: OrgId

        @required
        name: String

        description: String

        @required
        permissions: OrgPermissionList
    }

    output := {
        @required
        customRole: OrgCustomRole
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "roles", pageSize: "limit")
@http(method: "POST", uri: "/orgs/roles/list")
operation ListOrgCustomRoles {
    input := {
        @required
        orgId: OrgId

        /// Pagination cursor (encoded roleId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        roles: OrgCustomRoleMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}


@http(method: "POST", uri: "/orgs/roles/update")
operation UpdateOrgCustomRole {
    input := {
        @required
        orgId: OrgId

        @required
        customRoleId: OrgCustomRoleId

        name: String
        description: String
        permissions: OrgPermissionList
    }

    output := {
        @required
        customRole: OrgCustomRole
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/roles/delete")
operation DeleteOrgCustomRole {
    input := {
        @required
        orgId: OrgId

        @required
        customRoleId: OrgCustomRoleId
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ==================== INVITATION MANAGEMENT APIs ====================

@idempotent
@http(method: "POST", uri: "/orgs/invites/create")
operation CreateOrgInvite {
    input := {
        @required
        orgId: OrgId

        @required
        emails: EmailList

        @required
        role: OrgRole

        customRoleId: OrgCustomRoleId
        orgEmail: Email
    }

    output := {
        @required
        invites: OrgInviteMap

        failedEmails: EmailList
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@readonly
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "invites", pageSize: "limit")
@http(method: "POST", uri: "/orgs/invites/list")
operation ListOrgInvites {
    input := {
        @required
        orgId: OrgId

        /// Filter by invite status
        status: InviteStatus

        /// Pagination cursor (encoded inviteId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        invites: OrgInviteMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/invites/cancel")
operation CancelOrgInvite {
    input := {
        @required
        orgId: OrgId

        @required
        inviteId: InviteId
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/orgs/invites/resend")
operation ResendOrgInvite {
    input := {
        @required
        orgId: OrgId

        @required
        inviteId: InviteId

        expiresDate: ISODate
    }

    output := {
        @required
        invite: OrgInvite
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@http(method: "POST", uri: "/orgs/invites/accept")
operation AcceptOrgInvite {
    input := {
        @required
        orgId: OrgId

        @required
        inviteId: InviteId
    }

    output := {
        @required
        organization: Org

        @required
        member: OrgMember
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@http(method: "POST", uri: "/orgs/invites/decline")
operation DeclineOrgInvite {
    input := {
        @required
        orgId: OrgId

        @required
        inviteId: InviteId
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// ==================== ORG PROFILE PICTURE APIs ====================

@http(method: "POST", uri: "/orgs/getOrgPicture")
operation GetOrgPicture {
    input := {
        @required
        orgId: OrgId
    }

    output := {
        @required
        profilePictureURL: Url
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/orgs/uploadOrgPicture")
operation UploadOrgPicture {
    input := {
        @required
        orgId: OrgId
    }

    output := {
        @required
        urlInfo: PresignedPostData
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// ==================== ORG THEME APIs ====================

@http(method: "POST", uri: "/orgs/getOrgTheme")
operation GetOrgTheme {
    input := {
        @required
        orgId: OrgId
    }

    output := {
        @required
        theme: OrgTheme
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/orgs/updateOrgTheme")
operation UpdateOrgTheme {
    input := {
        @required
        orgId: OrgId

        @required
        theme: OrgTheme
    }

    output := {
        @required
        theme: OrgTheme
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}