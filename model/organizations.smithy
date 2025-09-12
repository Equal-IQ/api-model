$version: "2"

namespace equaliq

// Org structures and operations

string OrgId with [UuidLikeMixin]
string InviteId with [UuidLikeMixin]
string OrgCustomRoleId with [UuidLikeMixin]

enum OrgType {
    LAW_FIRM = "law_firm"
    RECORD_LABEL = "record_label" 
    MANAGEMENT_COMPANY = "management_company"
    PUBLISHING_COMPANY = "publishing_company"
    PRODUCTION_COMPANY = "production_company"
    TALENT_AGENCY = "talent_agency"
    DISTRIBUTION_COMPANY = "distribution_company"
    OTHER = "other"
}

enum OrgRole {
    PRIMARY_OWNER = "primary_owner"
    ADMIN = "admin"
    BILLING_ADMIN = "billing_admin"
    MEMBER = "member"
    VIEWER = "viewer"
    CUSTOM = "custom"
}

enum InviteStatus {
    PENDING = "pending"
    ACCEPTED = "accepted"
    DECLINED = "declined"
    EXPIRED = "expired"
}

enum OrgPermission {
    MANAGE_MEMBERS = "manage_members"
    MANAGE_BILLING = "manage_billing"
    MANAGE_SETTINGS = "manage_settings"
    VIEW_ALL_CONTRACTS = "view_all_contracts"
    MANAGE_CONTRACTS = "manage_contracts"
    INVITE_USERS = "invite_users"
    MANAGE_ROLES = "manage_roles"
    VIEW_ANALYTICS = "view_analytics"
}

list OrgPermissionList {
    member: OrgPermission
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
    type: OrgType

    @required
    primaryOwner: UserId

    description: String
    website: Url
    logoUrl: Url
    
    billingEmail: Email

    @required
    createdDate: ISODate

    memberCount: Integer
    
    // Frontend-specific fields
    userRole: OrgRole
    contractCount: Integer
    inviteCount: Integer
    roleCount: Integer
}

structure OrgMember {
    @required
    userId: UserId

    @required
    orgEmail: Email

    @required
    role: OrgRole

    customRoleId: OrgCustomRoleId
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    joinedDate: ISODate

    userProfile: UserProfile
}

structure OrgInvite {
    @required
    inviteId: InviteId

    @required
    orgId: OrgId

    @required
    invitedEmail: Email

    @required
    role: OrgRole

    customRoleId: OrgCustomRoleId
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    invitedBy: UserId
    invitedByProfile: UserProfile

    @required
    status: InviteStatus

    @required
    createdDate: ISODate

    expiresDate: ISODate
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
    resources: [OrganizationMember, OrganizationInvite, OrgCustomRoleResource]
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

resource OrgCustomRoleResource {
    identifiers: { orgId: OrgId, customRoleId: OrgCustomRoleId }
    create: CreateOrgCustomRole
    list: ListOrgCustomRoles
    update: UpdateOrgCustomRole
    delete: DeleteOrgCustomRole
}

// ==================== ORGANIZATION MANAGEMENT APIs ====================

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@http(method: "POST", uri: "/orgs/listUserOrganizations")
operation ListUserOrganizations {
    input: ListUserOrganizationsInput
    output: ListUserOrganizationsOutput
    errors: [
        AuthenticationError
        InternalServerError
    ]
}

structure ListUserOrganizationsInput {
    // No input parameters - uses current user from auth
}

structure ListUserOrganizationsOutput {
    @required
    organizations: OrgList
}

list OrgList {
    member: Org
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@http(method: "POST", uri: "/orgs/get")
operation GetOrg {
    input: GetOrgInput
    output: GetOrgOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetOrgInput {
    @required
    orgId: OrgId
}

structure GetOrgOutput {
    @required
    org: Org
}

@idempotent
@http(method: "POST", uri: "/orgs/create")
operation CreateOrg {
    input: CreateOrgInput
    output: CreateOrgOutput
    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

structure CreateOrgInput {
    @required
    name: String

    @required
    type: OrgType

    description: String
    website: Url
    
    @required
    billingEmail: Email
}

structure CreateOrgOutput {
    @required
    success: Boolean

    @required
    org: Org
}

@http(method: "POST", uri: "/orgs/update")
operation UpdateOrg {
    input: UpdateOrgInput
    output: UpdateOrgOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrgInput {
    @required
    orgId: OrgId

    name: String
    description: String
    website: Url
    billingEmail: Email
}

structure UpdateOrgOutput {
    @required
    success: Boolean

    @required
    org: Org
}

@idempotent
@http(method: "POST", uri: "/orgs/delete")
operation DeleteOrg {
    input: DeleteOrgInput
    output: DeleteOrgOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure DeleteOrgInput {
    @required
    orgId: OrgId
}

structure DeleteOrgOutput {
    @required
    success: Boolean
}

// ==================== MEMBER MANAGEMENT APIs ====================

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@readonly
@http(method: "POST", uri: "/orgs/members/list")
operation ListOrgMembers {
    input: ListOrgMembersInput
    output: ListOrgMembersOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListOrgMembersInput {
    @required
    orgId: OrgId
}

structure ListOrgMembersOutput {
    @required
    members: OrgMemberMap
}

@http(method: "POST", uri: "/orgs/updateMember")
operation UpdateOrgMember {
    input: UpdateOrgMemberInput
    output: UpdateOrgMemberOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrgMemberInput {
    @required
    orgId: OrgId

    @required
    userId: UserId

    role: OrgRole
    customRoleId: OrgCustomRoleId
    orgEmail: Email
}

structure UpdateOrgMemberOutput {
    @required
    success: Boolean

    @required
    member: OrgMember
}

@idempotent
@http(method: "POST", uri: "/orgs/removeMember")
operation RemoveOrgMember {
    input: RemoveOrgMemberInput
    output: RemoveOrgMemberOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure RemoveOrgMemberInput {
    @required
    orgId: OrgId

    @required
    userId: UserId
}

structure RemoveOrgMemberOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/orgs/transferOwnership")
operation TransferOrgOwnership {
    input: TransferOrgOwnershipInput
    output: TransferOrgOwnershipOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure TransferOrgOwnershipInput {
    @required
    orgId: OrgId

    @required
    newOwnerId: UserId
}

structure TransferOrgOwnershipOutput {
    @required
    success: Boolean

    @required
    org: Org
}

// ==================== ROLE MANAGEMENT APIs ====================

@idempotent
@http(method: "POST", uri: "/orgs/roles/create")
operation CreateOrgCustomRole {
    input: CreateOrgCustomRoleInput
    output: CreateOrgCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CreateOrgCustomRoleInput {
    @required
    orgId: OrgId

    @required
    name: String

    description: String

    @required
    permissions: OrgPermissionList
}

structure CreateOrgCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: OrgCustomRole
}

@readonly
@http(method: "POST", uri: "/orgs/roles/list")
operation ListOrgCustomRoles {
    input: ListOrgCustomRolesInput
    output: ListOrgCustomRolesOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListOrgCustomRolesInput {
    @required
    orgId: OrgId
}

structure ListOrgCustomRolesOutput {
    @required
    roles: OrgCustomRoleMap
}


@http(method: "POST", uri: "/orgs/roles/update")
operation UpdateOrgCustomRole {
    input: UpdateOrgCustomRoleInput
    output: UpdateOrgCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrgCustomRoleInput {
    @required
    orgId: OrgId

    @required
    customRoleId: OrgCustomRoleId

    name: String
    description: String
    permissions: OrgPermissionList
}

structure UpdateOrgCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: OrgCustomRole
}

@idempotent
@http(method: "POST", uri: "/orgs/roles/delete")
operation DeleteOrgCustomRole {
    input: DeleteOrgCustomRoleInput
    output: DeleteOrgCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure DeleteOrgCustomRoleInput {
    @required
    orgId: OrgId

    @required
    customRoleId: OrgCustomRoleId
}

structure DeleteOrgCustomRoleOutput {
    @required
    success: Boolean
}

// ==================== INVITATION MANAGEMENT APIs ====================

@idempotent
@http(method: "POST", uri: "/orgs/invites/create")
operation CreateOrgInvite {
    input: CreateOrgInviteInput
    output: CreateOrgInviteOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CreateOrgInviteInput {
    @required
    orgId: OrgId

    @required
    emails: EmailList

    @required
    role: OrgRole

    customRoleId: OrgCustomRoleId
    orgEmail: Email
}

structure CreateOrgInviteOutput {
    @required
    success: Boolean

    @required
    invites: OrgInviteMap

    failedEmails: EmailList
}

@readonly
@http(method: "POST", uri: "/orgs/invites/list")
operation ListOrgInvites {
    input: ListOrgInvitesInput
    output: ListOrgInvitesOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListOrgInvitesInput {
    @required
    orgId: OrgId

    status: InviteStatus
}

structure ListOrgInvitesOutput {
    @required
    invites: OrgInviteMap
}

@idempotent
@http(method: "POST", uri: "/orgs/invites/cancel")
operation CancelOrgInvite {
    input: CancelOrgInviteInput
    output: CancelOrgInviteOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CancelOrgInviteInput {
    @required
    orgId: OrgId

    @required
    inviteId: InviteId
}

structure CancelOrgInviteOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/orgs/invites/resend")
operation ResendOrgInvite {
    input: ResendOrgInviteInput
    output: ResendOrgInviteOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure ResendOrgInviteInput {
    @required
    orgId: OrgId

    @required
    inviteId: InviteId

    expiresDate: ISODate

}

structure ResendOrgInviteOutput {
    @required
    success: Boolean

    @required
    invite: OrgInvite
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@http(method: "POST", uri: "/orgs/invites/accept")
operation AcceptOrgInvite {
    input: AcceptOrgInviteInput
    output: AcceptOrgInviteOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure AcceptOrgInviteInput {
    @required
    orgId: OrgId

    @required
    inviteId: InviteId
}

structure AcceptOrgInviteOutput {
    @required
    success: Boolean

    @required
    organization: Org

    @required
    member: OrgMember
}

@tags(["TODOFEIMPL", "TODOBESTUB", "TODOBEIMPL"])
@http(method: "POST", uri: "/orgs/invites/decline")
operation DeclineOrgInvite {
    input: DeclineOrgInviteInput
    output: DeclineOrgInviteOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure DeclineOrgInviteInput {
    @required
    orgId: OrgId

    @required
    inviteId: InviteId
}

structure DeclineOrgInviteOutput {
    @required
    success: Boolean
}

// ==================== ORG PROFILE PICTURE APIs ====================

@http(method: "POST", uri: "/orgs/getOrgPicture")
operation GetOrgPicture {
    input: GetOrgPictureInput
    output: GetOrgPictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetOrgPictureInput {
    @required
    orgId: OrgId
}

structure GetOrgPictureOutput {
    @required
    profilePictureURL: Url
}

@http(method: "POST", uri: "/orgs/uploadOrgPicture")
operation UploadOrgPicture {
    input: UploadOrgPictureInput
    output: UploadOrgPictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure UploadOrgPictureInput {
    @required
    orgId: OrgId
}

structure UploadOrgPictureOutput {
    @required
    url_info: PresignedPostData
}

// ==================== ORG THEME APIs ====================

@http(method: "POST", uri: "/orgs/getOrgTheme")
operation GetOrgTheme {
    input: GetOrgThemeInput
    output: GetOrgThemeOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetOrgThemeInput {
    @required
    orgId: OrgId
}

structure GetOrgThemeOutput {
    @required
    theme: OrgTheme
}

@idempotent
@http(method: "POST", uri: "/orgs/updateOrgTheme")
operation UpdateOrgTheme {
    input: UpdateOrgThemeInput
    output: UpdateOrgThemeOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrgThemeInput {
    @required
    orgId: OrgId

    @required
    theme: OrgTheme
}

structure UpdateOrgThemeOutput {
    @required
    success: Boolean

    @required
    theme: OrgTheme
}