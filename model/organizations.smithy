$version: "2"

namespace equaliq

// Org structures and operations

string OrgId with [UuidLikeMixin]
string InviteId with [UuidLikeMixin]
string CustomRoleId with [UuidLikeMixin]

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

map CustomRoleMap {
    key: CustomRoleId
    value: CustomRole
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
    
    billingEmail: Email

    @required
    createdDate: ISODate

    memberCount: Integer
}

structure OrgMember {
    @required
    userId: UserId

    @required
    orgEmail: Email

    @required
    role: OrgRole

    customRoleId: CustomRoleId
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

    customRoleId: CustomRoleId
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

structure CustomRole {
    @required
    customRoleId: CustomRoleId

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
}

structure OrgTheme {
    primaryColor: HexColor
    secondaryColor: HexColor
    accentColor: HexColor
}

// ==================== ORGANIZATION MANAGEMENT APIs ====================

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
    customRoleId: CustomRoleId
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
operation CreateCustomRole {
    input: CreateCustomRoleInput
    output: CreateCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CreateCustomRoleInput {
    @required
    orgId: OrgId

    @required
    name: String

    description: String

    @required
    permissions: OrgPermissionList
}

structure CreateCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: CustomRole
}

@http(method: "POST", uri: "/orgs/roles/list")
operation ListCustomRoles {
    input: ListCustomRolesInput
    output: ListCustomRolesOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListCustomRolesInput {
    @required
    orgId: OrgId
}

structure ListCustomRolesOutput {
    @required
    roles: CustomRoleMap
}


@http(method: "POST", uri: "/orgs/roles/update")
operation UpdateCustomRole {
    input: UpdateCustomRoleInput
    output: UpdateCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateCustomRoleInput {
    @required
    orgId: OrgId

    @required
    customRoleId: CustomRoleId

    name: String
    description: String
    permissions: OrgPermissionList
}

structure UpdateCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: CustomRole
}

@idempotent
@http(method: "POST", uri: "/orgs/roles/delete")
operation DeleteCustomRole {
    input: DeleteCustomRoleInput
    output: DeleteCustomRoleOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure DeleteCustomRoleInput {
    @required
    orgId: OrgId

    @required
    customRoleId: CustomRoleId
}

structure DeleteCustomRoleOutput {
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

    customRoleId: CustomRoleId
    orgEmail: Email
}

structure CreateOrgInviteOutput {
    @required
    success: Boolean

    @required
    invites: OrgInviteMap

    failedEmails: EmailList
}

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