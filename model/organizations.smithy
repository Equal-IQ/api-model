$version: "2"

namespace equaliq

// Organization structures and operations

string OrganizationId with [UuidLikeMixin]
string InvitationId with [UuidLikeMixin]
string CustomRoleId with [UuidLikeMixin]

enum OrganizationType {
    LAW_FIRM = "law_firm"
    RECORD_LABEL = "record_label" 
    MANAGEMENT_COMPANY = "management_company"
    PUBLISHING_COMPANY = "publishing_company"
    PRODUCTION_COMPANY = "production_company"
    TALENT_AGENCY = "talent_agency"
    DISTRIBUTION_COMPANY = "distribution_company"
    OTHER = "other"
}

enum OrganizationRole {
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

enum OrganizationPermission {
    MANAGE_MEMBERS = "manage_members"
    MANAGE_BILLING = "manage_billing"
    MANAGE_SETTINGS = "manage_settings"
    VIEW_ALL_CONTRACTS = "view_all_contracts"
    MANAGE_CONTRACTS = "manage_contracts"
    INVITE_USERS = "invite_users"
    MANAGE_ROLES = "manage_roles"
    VIEW_ANALYTICS = "view_analytics"
}

list PermissionList {
    member: OrganizationPermission
}

list OrganizationMemberList {
    member: OrganizationMember
}

list OrganizationInvitationList {
    member: OrganizationInvitation
}

list CustomRoleList {
    member: CustomRole
}

structure Organization {
    @required
    organizationId: OrganizationId

    @required
    name: String

    @required
    type: OrganizationType

    @required
    primaryOwner: UserId

    description: String
    website: Url
    billingEmail: Email

    @required
    createdDate: ISODate

    @required
    memberCount: Integer
}

structure OrganizationMember {
    @required
    userId: UserId

    @required
    organizationEmail: Email

    @required
    role: OrganizationRole

    customRoleId: CustomRoleId
    customRoleName: String
    customPermissions: PermissionList

    @required
    joinedDate: ISODate

    userProfile: UserProfile
}

structure OrganizationInvitation {
    @required
    invitationId: InvitationId

    @required
    organizationId: OrganizationId

    @required
    invitedEmail: Email

    @required
    role: OrganizationRole

    customRoleId: CustomRoleId
    customRoleName: String
    customPermissions: PermissionList

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
    organizationId: OrganizationId

    @required
    name: String

    description: String

    @required
    permissions: PermissionList

    @required
    createdDate: ISODate

    @required
    createdBy: UserId
}

// ==================== ORGANIZATION MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/create")
operation CreateOrganization {
    input: CreateOrganizationInput
    output: CreateOrganizationOutput
    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

structure CreateOrganizationInput {
    @required
    name: String

    @required
    type: OrganizationType

    description: String
    website: Url
    billingEmail: Email
}

structure CreateOrganizationOutput {
    @required
    success: Boolean

    @required
    organization: Organization
}

@http(method: "POST", uri: "/organizations/update")
operation UpdateOrganization {
    input: UpdateOrganizationInput
    output: UpdateOrganizationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrganizationInput {
    @required
    organizationId: OrganizationId

    name: String
    description: String
    website: Url
    billingEmail: Email
}

structure UpdateOrganizationOutput {
    @required
    success: Boolean

    @required
    organization: Organization
}

@http(method: "POST", uri: "/organizations/delete")
operation DeleteOrganization {
    input: DeleteOrganizationInput
    output: DeleteOrganizationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure DeleteOrganizationInput {
    @required
    organizationId: OrganizationId
}

structure DeleteOrganizationOutput {
    @required
    success: Boolean
}

// ==================== MEMBER MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/invite")
operation InviteToOrganization {
    input: InviteToOrganizationInput
    output: InviteToOrganizationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure InviteToOrganizationInput {
    @required
    organizationId: OrganizationId

    @required
    emails: EmailList

    @required
    role: OrganizationRole

    customRoleId: CustomRoleId
    organizationEmail: Email
}

structure InviteToOrganizationOutput {
    @required
    success: Boolean

    @required
    invitations: OrganizationInvitationList

    failedEmails: EmailList
}

@http(method: "POST", uri: "/organizations/updateMember")
operation UpdateOrganizationMember {
    input: UpdateOrganizationMemberInput
    output: UpdateOrganizationMemberOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure UpdateOrganizationMemberInput {
    @required
    organizationId: OrganizationId

    @required
    userId: UserId

    role: OrganizationRole
    customRoleId: CustomRoleId
    organizationEmail: Email
}

structure UpdateOrganizationMemberOutput {
    @required
    success: Boolean

    @required
    member: OrganizationMember
}

@http(method: "POST", uri: "/organizations/removeMember")
operation RemoveOrganizationMember {
    input: RemoveOrganizationMemberInput
    output: RemoveOrganizationMemberOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure RemoveOrganizationMemberInput {
    @required
    organizationId: OrganizationId

    @required
    userId: UserId
}

structure RemoveOrganizationMemberOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/organizations/transferOwnership")
operation TransferOrganizationOwnership {
    input: TransferOrganizationOwnershipInput
    output: TransferOrganizationOwnershipOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure TransferOrganizationOwnershipInput {
    @required
    organizationId: OrganizationId

    @required
    newOwnerId: UserId
}

structure TransferOrganizationOwnershipOutput {
    @required
    success: Boolean

    @required
    organization: Organization
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
    organizationId: OrganizationId

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
    organizationId: OrganizationId

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
    organizationId: OrganizationId

    @required
    customRoleId: CustomRoleId
}

structure DeleteCustomRoleOutput {
    @required
    success: Boolean
}

// ==================== INVITATION MANAGEMENT APIs ====================

@http(method: "POST", uri: "/organizations/invitations")
operation ListOrganizationInvitations {
    input: ListOrganizationInvitationsInput
    output: ListOrganizationInvitationsOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure ListOrganizationInvitationsInput {
    @required
    organizationId: OrganizationId

    status: InvitationStatus
}

structure ListOrganizationInvitationsOutput {
    @required
    invitations: OrganizationInvitationList
}

@http(method: "POST", uri: "/organizations/invitations/cancel")
operation CancelOrganizationInvitation {
    input: CancelOrganizationInvitationInput
    output: CancelOrganizationInvitationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure CancelOrganizationInvitationInput {
    @required
    organizationId: OrganizationId

    @required
    invitationId: InvitationId
}

structure CancelOrganizationInvitationOutput {
    @required
    success: Boolean
}

@http(method: "POST", uri: "/organizations/invitations/resend")
operation ResendOrganizationInvitation {
    input: ResendOrganizationInvitationInput
    output: ResendOrganizationInvitationOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

structure ResendOrganizationInvitationInput {
    @required
    organizationId: OrganizationId

    @required
    invitationId: InvitationId
}

structure ResendOrganizationInvitationOutput {
    @required
    success: Boolean

    @required
    invitation: OrganizationInvitation
}