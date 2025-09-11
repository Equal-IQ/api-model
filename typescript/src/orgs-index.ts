// Auto-generated index file with unwrapped types for orgs API
// Export all schemas from the OpenAPI specification
export * from './orgs-models';
export { components } from './orgs-models';

// Re-export schemas as top-level types for easier importing
import { components } from './orgs-models';
export type Schemas = components['schemas'];

// Unwrapped enum definitions
export enum AccountType {
  artist = "artist",
  manager = "manager",
  lawyer = "lawyer",
  producer = "producer",
  publisher = "publisher",
  executive = "executive"
}

export enum InvitationStatus {
  pending = "pending",
  accepted = "accepted",
  declined = "declined",
  expired = "expired"
}

export enum OrgPermission {
  manage_members = "manage_members",
  manage_billing = "manage_billing",
  manage_settings = "manage_settings",
  view_all_contracts = "view_all_contracts",
  manage_contracts = "manage_contracts",
  invite_users = "invite_users",
  manage_roles = "manage_roles",
  view_analytics = "view_analytics"
}

export enum OrgRole {
  primary_owner = "primary_owner",
  admin = "admin",
  billing_admin = "billing_admin",
  member = "member",
  viewer = "viewer",
  custom = "custom"
}

export enum OrgType {
  law_firm = "law_firm",
  record_label = "record_label",
  management_company = "management_company",
  publishing_company = "publishing_company",
  production_company = "production_company",
  talent_agency = "talent_agency",
  distribution_company = "distribution_company",
  other = "other"
}

// Unwrapped type definitions (no aliases)
export type CancelOrgInvitationRequestContent = {
  organizationId: string;
  invitationId: string;
};

export type CancelOrgInvitationResponseContent = {
  success: boolean;
};

export type CreateCustomRoleRequestContent = {
  organizationId: string;
  name: string;
  description?: string;
  permissions: OrgPermission[];
};

export type CreateCustomRoleResponseContent = {
  success: boolean;
  customRole: CustomRole;
};

export type CreateOrgRequestContent = {
  name: string;
  type: OrgType;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type CreateOrgResponseContent = {
  success: boolean;
  organization: Org;
};

export type CustomRole = {
  customRoleId: string;
  organizationId: string;
  name: string;
  description?: string;
  permissions: OrgPermission[];
  createdDate: string;
  createdBy: string;
};

export type DeleteCustomRoleRequestContent = {
  organizationId: string;
  customRoleId: string;
};

export type DeleteCustomRoleResponseContent = {
  success: boolean;
};

export type DeleteOrgRequestContent = {
  organizationId: string;
};

export type DeleteOrgResponseContent = {
  success: boolean;
};

export type InternalServerErrorResponseContent = {
  message: string;
};

export type InviteToOrgRequestContent = {
  organizationId: string;
  emails: string[];
  role: OrgRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type InviteToOrgResponseContent = {
  success: boolean;
  invitations: OrgInvitation[];
  failedEmails?: string[];
};

export type ListOrgInvitationsRequestContent = {
  organizationId: string;
  status?: InvitationStatus;
};

export type ListOrgInvitationsResponseContent = {
  invitations: OrgInvitation[];
};

export type Org = {
  organizationId: string;
  name: string;
  type: OrgType;
  primaryOwner: string;
  description?: string;
  website?: string;
  billingEmail?: string;
  createdDate: string;
  memberCount?: number;
};

export type OrgInvitation = {
  invitationId: string;
  organizationId: string;
  invitedEmail: string;
  role: OrgRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrgPermission[];
  invitedBy: string;
  status: InvitationStatus;
  createdDate: string;
  expiresDate?: string;
  inviterProfile?: UserProfile;
};

export type OrgMember = {
  userId: string;
  organizationEmail: string;
  role: OrgRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrgPermission[];
  joinedDate: string;
  userProfile?: UserProfile;
};

export type RemoveOrgMemberRequestContent = {
  organizationId: string;
  userId: string;
};

export type RemoveOrgMemberResponseContent = {
  success: boolean;
};

export type ResendOrgInvitationRequestContent = {
  organizationId: string;
  invitationId: string;
};

export type ResendOrgInvitationResponseContent = {
  success: boolean;
  invitation: OrgInvitation;
};

export type ResourceNotFoundErrorResponseContent = {
  message: string;
};

export type TransferOrgOwnershipRequestContent = {
  organizationId: string;
  newOwnerId: string;
};

export type TransferOrgOwnershipResponseContent = {
  success: boolean;
  organization: Org;
};

export type UpdateCustomRoleRequestContent = {
  organizationId: string;
  customRoleId: string;
  name?: string;
  description?: string;
  permissions?: OrgPermission[];
};

export type UpdateCustomRoleResponseContent = {
  success: boolean;
  customRole: CustomRole;
};

export type UpdateOrgMemberRequestContent = {
  organizationId: string;
  userId: string;
  role?: OrgRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type UpdateOrgMemberResponseContent = {
  success: boolean;
  member: OrgMember;
};

export type UpdateOrgRequestContent = {
  organizationId: string;
  name?: string;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type UpdateOrgResponseContent = {
  success: boolean;
  organization: Org;
};

export type UserProfile = {
  userId?: string;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  email?: string;
  accountType?: AccountType;
  bio?: string;
};

export type ValidationErrorResponseContent = {
  message: string;
};
