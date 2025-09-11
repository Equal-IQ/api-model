$version: "2"

namespace equaliq

// Organization structures and operations

string OrgId with [UuidLikeMixin]
string InvitationId with [UuidLikeMixin]
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

enum InvitationStatus {
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

list OrgMemberList {
    member: OrgMember
}

list OrgInvitationList {
    member: OrgInvitation
}

list CustomRoleList {
    member: CustomRole
}

structure Org {
    @required
    organizationId: OrgId

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
    organizationEmail: Email

    @required
    role: OrgRole

    customRoleId: CustomRoleId
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    joinedDate: ISODate

    userProfile: UserProfile
}

structure OrgInvitation {
    @required
    invitationId: InvitationId

    @required
    organizationId: OrgId

    @required
    invitedEmail: Email

    @required
    role: OrgRole

    customRoleId: CustomRoleId
    customRoleName: String
    customPermissions: OrgPermissionList

    @required
    invitedBy: UserId

    @required
    status: InvitationStatus

    @required
    createdDate: ISODate

    expiresDate: ISODate
    inviterProfile: UserProfile
}

structure CustomRole {
    @required
    customRoleId: CustomRoleId

    @required
    organizationId: OrgId

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

// ==================== ORGANIZATION MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/create")
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
    billingEmail: Email
}

structure CreateOrgOutput {
    @required
    success: Boolean

    @required
    organization: Org
}

@http(method: "POST", uri: "/organizations/update")
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
    organizationId: OrgId

    name: String
    description: String
    website: Url
    billingEmail: Email
}

structure UpdateOrgOutput {
    @required
    success: Boolean

    @required
    organization: Org
}

@http(method: "POST", uri: "/organizations/delete")
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
    organizationId: OrgId
}

structure DeleteOrgOutput {
    @required
    success: Boolean
}

// ==================== MEMBER MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/invite")
operation InviteToOrg {
    input: InviteToOrgInput
    output: InviteToOrgOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure InviteToOrgInput {
    @required
    organizationId: OrgId

    @required
    emails: EmailList

    @required
    role: OrganizationRole

    customRoleId: CustomRoleId
    organizationEmail: Email
}

structure InviteToOrgOutput {
    @required
    success: Boolean

    @required
    invitations: OrganizationInvitationList

    failedEmails: EmailList
}

@http(method: "POST", uri: "/organizations/updateMember")
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
    organizationId: OrgId

    @required
    userId: UserId

    role: OrganizationRole
    customRoleId: CustomRoleId
    organizationEmail: Email
}

structure UpdateOrgMemberOutput {
    @required
    success: Boolean

    @required
    member: OrganizationMember
}

@http(method: "POST", uri: "/organizations/removeMember")
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
    organizationId: OrgId

    @required
    userId: UserId
}

structure RemoveOrgMemberOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/organizations/transferOwnership")
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
    organizationId: OrgId

    @required
    newOwnerId: UserId
}

structure TransferOrgOwnershipOutput {
    @required
    success: Boolean

    @required
    organization: Org
}

// ==================== ROLE MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/roles/create")
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
    organizationId: OrgId

    @required
    name: String

    description: String

    @required
    permissions: PermissionList
}

structure CreateCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: CustomRole
}

@http(method: "POST", uri: "/organizations/roles/update")
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
    organizationId: OrgId

    @required
    customRoleId: CustomRoleId

    name: String
    description: String
    permissions: PermissionList
}

structure UpdateCustomRoleOutput {
    @required
    success: Boolean

    @required
    customRole: CustomRole
}

@http(method: "POST", uri: "/organizations/roles/delete")
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
    organizationId: OrgId

    @required
    customRoleId: CustomRoleId
}

structure DeleteCustomRoleOutput {
    @required
    success: Boolean
}

// ==================== INVITATION MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/invitations")
operation ListOrgInvitations {
    input: ListOrgInvitationsInput
    output: ListOrgInvitationsOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListOrgInvitationsInput {
    @required
    organizationId: OrgId

    status: InvitationStatus
}

structure ListOrgInvitationsOutput {
    @required
    invitations: OrganizationInvitationList
}

@http(method: "POST", uri: "/organizations/invitations/cancel")
operation CancelOrgInvitation {
    input: CancelOrgInvitationInput
    output: CancelOrgInvitationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CancelOrgInvitationInput {
    @required
    organizationId: OrgId

    @required
    invitationId: InvitationId
}

structure CancelOrgInvitationOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/organizations/invitations/resend")
operation ResendOrgInvitation {
    input: ResendOrgInvitationInput
    output: ResendOrgInvitationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure ResendOrgInvitationInput {
    @required
    organizationId: OrgId

    @required
    invitationId: InvitationId
}

structure ResendOrgInvitationOutput {
    @required
    success: Boolean

    @required
    invitation: OrganizationInvitation
}