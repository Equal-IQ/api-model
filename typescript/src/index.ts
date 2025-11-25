// Auto-generated index file with unwrapped types
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
export type Schemas = components['schemas'];

// Unwrapped enum definitions
export enum ContractStatus {
  processing = "processing",
  awaiting_upload = "awaiting_upload",
  extracting_text = "extracting_text",
  eq_generation = "eq_generation",
  iq_generation = "iq_generation",
  variable_extraction = "variable_extraction",
  contract_markup = "contract_markup",
  tts_generation = "tts_generation",
  complete = "complete",
  error = "error"
}

export enum ContractVariableType {
  eq_term = "eq_term",
  discovered_term = "discovered_term",
  external_term = "external_term",
  internal_citation = "internal_citation"
}

export enum DurationType {
  fixed = "fixed",
  indefinite = "indefinite",
  renewable = "renewable",
  other = "other"
}

export enum EqCardKey {
  moneyYouReceive = "moneyYouReceive",
  whatYouOwn = "whatYouOwn",
  whatYoureResponsibleFor = "whatYoureResponsibleFor",
  howLongThisDealLasts = "howLongThisDealLasts",
  risksCostsLegalStuff = "risksCostsLegalStuff"
}

export enum EqCardType {
  A = "A",
  B = "B"
}

export enum FlagSeverity {
  critical = "critical",
  warn = "warn",
  info = "info",
  positive = "positive"
}

export enum InviteStatus {
  pending = "pending",
  accepted = "accepted",
  declined = "declined",
  expired = "expired"
}

export enum IqModeSectionKey {
  earnings = "earnings",
  qualityOfRights = "qualityOfRights",
  usageObligations = "usageObligations",
  agreementLength = "agreementLength",
  liabilitySafeguards = "liabilitySafeguards"
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

// Unwrapped type definitions (no aliases)
export type AcceptOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
};

export type AcceptOrgInviteResponseContent = {
  success: boolean;
  organization: Org;
  member: OrgMember;
};

export type AuthenticationErrorResponseContent = {
  message: string;
};

export type CancelOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
};

export type CancelOrgInviteResponseContent = {
  success: boolean;
};

export type ContractAnalysisRecord = {
  contractId: string;
  name: string;
  type: string;
  status: ContractStatus;
  uploadedOn: string;
  ownerId: string;
  eqCards?: EqModeData;
  iqData: IqModeData;
  extractedType?: string;
  parties?: string[];
  terms?: ExtractionTermMap;
  variables?: ContractVariableMap;
  contractTexts?: ContractTexts;
  sharedUsers?: SharedUserDetails[];
  hasTTS?: boolean;
  isSpecial?: boolean;
};

export type ContractExtractionResult = {
  extractedType?: string;
  parties?: string[];
  terms?: ExtractionTermMap;
  variables?: ContractVariableMap;
  contractTexts?: ContractTexts;
};

export type ContractMetadata = {
  contractId: string;
  name: string;
  type: string;
  status: ContractStatus;
  uploadedOn: string;
  ownerId: string;
  sharedUsers?: SharedUserDetails[];
  isOwner?: boolean;
  hasTTS?: boolean;
  isSpecial?: boolean;
};

export type ContractSummaryItem = {
  contractId: string;
  name: string;
  uploadedOn: number;
  type: string;
  status: ContractStatus;
  isOwner: boolean;
  ownerId: string;
  sharedWith?: string[];
  sharedUsers?: string[];
  sharedEmails?: string[];
};

export type ContractTexts = {
  originalText?: PlainText;
  taggedText?: TaggedText;
};

export type ContractVariable = {
  name: string;
  type: ContractVariableType;
  id: string;
  value?: string;
  level?: number;
  confidence?: number;
  firstOccurrence?: number;
  context?: string;
  variations?: string[];
  referencedSection?: string;
  definitionCitation?: string;
};

export type ContractVariableMap = { [key: string]: ContractVariable };

export type CreateOrgCustomRoleRequestContent = {
  orgId: string;
  name: string;
  description?: string;
  permissions: OrgPermission[];
};

export type CreateOrgCustomRoleResponseContent = {
  success: boolean;
  customRole: OrgCustomRole;
};

export type CreateOrgInviteRequestContent = {
  orgId: string;
  emails: string[];
  role: OrgRole;
  customRoleId?: string;
  orgEmail?: string;
};

export type CreateOrgInviteResponseContent = {
  success: boolean;
  invites: OrgInviteMap;
  failedEmails?: string[];
};

export type CreateOrgRequestContent = {
  name: string;
  type: string;
  description?: string;
  website?: string;
  billingEmail: string;
};

export type CreateOrgResponseContent = {
  success: boolean;
  org: Org;
};

export type DeclineOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
};

export type DeclineOrgInviteResponseContent = {
  success: boolean;
};

export type DeleteContractRequestContent = {
  contractId: string;
};

export type DeleteContractResponseContent = {
  success: boolean;
};

export type DeleteOrgCustomRoleRequestContent = {
  orgId: string;
  customRoleId: string;
};

export type DeleteOrgCustomRoleResponseContent = {
  success: boolean;
};

export type DeleteOrgRequestContent = {
  orgId: string;
};

export type DeleteOrgResponseContent = {
  success: boolean;
};

export type EmptyStructure = unknown;

export type EqCardUniqueData = {
  MONEY_RECEIVED: EqMoneyCard;
} | {
  OWNERSHIP: EqOwnershipCard;
} | {
  RESPONSIBILITIES: EqResponsibilitiesCard;
} | {
  DURATION: EqDurationCard;
} | {
  LEGAL: EqLegalCard;
} | {
  EMPTY: EmptyStructure;
};

export type EqDurationCard = {
  durationType: DurationType;
  durationText: string;
  durationDetails?: SimpleTermDescription[];
};

export type EqLegalCard = {
  risks: string;
  costs: string;
  legal: string;
};

export type EqModeCard = {
  id: EqCardKey;
  title: string;
  type: EqCardType;
  cardUniqueData: EqCardUniqueData;
  eqTitle?: string;
  subTitle?: string;
  totalAdvance?: string;
  items?: EqModeItem[];
  audioSrc?: string;
  ttsSrcUrl?: string;
  flags?: EqModeCardFlagMap;
};

export type EqModeCardFlag = {
  reasoning: string;
  referenceKey: string;
  severity: FlagSeverity;
  summary: string;
  context: string;
};

export type EqModeCardFlagMap = { [key: string]: EqModeCardFlag };

export type EqModeCardMap = { [key: string]: EqModeCard };

export type EqModeData = {
  cards?: EqModeCardMap;
};

export type EqModeItem = {
  title?: string;
  value?: string;
};

export type EqMoneyCard = {
  majorNumber: string;
  paidAfterList: string[];
};

export type EqOwnershipCard = {
  ownershipTerms: SimpleTermDescription[];
};

export type EqResponsibilitiesCard = {
  responsibilities: SimpleTermDescription[];
};

export type ExposeTypesResponseContent = {
  contractAnalysisRecord?: ContractAnalysisRecord;
};

export type ExtractionTerm = {
  name: string;
  definition: string;
  unitType: string;
  explanation: string;
  notes: string;
  citation: string;
  fixedValues?: FixedValueTermInference;
  fixedValueGuideline?: string;
  originalValue?: string;
};

export type ExtractionTermMap = { [key: string]: ExtractionTerm };

export type FixedTermValue = {
  unit: string;
  value: string;
  name?: string;
  numericValue?: number;
  condition?: string;
};

export type FixedValueTermInference = {
  primary: FixedTermValue;
  subterms?: FixedTermValue[];
};

export type GetContractReadURLRequestContent = {
  contractId: string;
};

export type GetContractReadURLResponseContent = {
  url: string;
};

export type GetContractRequestContent = {
  contractId: string;
};

export type GetContractResponseContent = {
  contractId: string;
  ownerId: string;
  name: string;
  type: string;
  eqData?: EqModeData;
  iqData?: IqModeData;
  contractExtraction?: ContractExtractionResult;
  sharedWith?: string[];
  isOwner?: boolean;
};

export type GetOrgPictureRequestContent = {
  orgId: string;
};

export type GetOrgPictureResponseContent = {
  profilePictureURL: string;
};

export type GetOrgRequestContent = {
  orgId: string;
};

export type GetOrgResponseContent = {
  org: Org;
};

export type GetOrgThemeRequestContent = {
  orgId: string;
};

export type GetOrgThemeResponseContent = {
  theme: OrgTheme;
};

export type GetProfilePictureRequestContent = {
  userId?: string;
};

export type GetProfilePictureResponseContent = {
  profilePictureURL: string;
};

export type GetProfileRequestContent = {
  userId?: string;
};

export type GetProfileResponseContent = {
  userId: string;
  profile: UserProfile;
};

export type GetSpecialContractRequestContent = {
  contractId: string;
};

export type GetSpecialContractResponseContent = {
  contractId: string;
  name: string;
  type: string;
  eqmode: unknown;
  sections: unknown;
  isOwner: boolean;
  ownerId: string;
  sharedWith: string[];
};

export type GetUploadURLRequestContent = {
  name: string;
};

export type GetUploadURLResponseContent = {
  url_info: PresignedPostData;
};

export type InternalServerErrorResponseContent = {
  message: string;
};

export type IqModeData = {
  iqModeData?: IqModePerspectiveMap;
};

export type IqModePerspective = {
  sections: IqModeSectionMap;
};

export type IqModePerspectiveMap = { [key: string]: IqModePerspective };

export type IqModeQuestion = {
  question: TaggedText;
  answer: TaggedText;
  ttsSrcUrl?: string;
};

export type IqModeSection = {
  id: IqModeSectionKey;
  sectionTitle: string;
  questions: IqModeQuestion[];
};

export type IqModeSectionMap = { [key: string]: IqModeSection };

export type ListContractsResponseContent = {
  owned?: ContractSummaryItem[];
  shared?: ContractSummaryItem[];
  contracts?: ContractMetadata[];
};

export type ListOrgCustomRolesRequestContent = {
  orgId: string;
};

export type ListOrgCustomRolesResponseContent = {
  roles: OrgCustomRoleMap;
};

export type ListOrgInvitesRequestContent = {
  orgId: string;
  status?: InviteStatus;
};

export type ListOrgInvitesResponseContent = {
  invites: OrgInviteMap;
};

export type ListOrgMembersRequestContent = {
  orgId: string;
};

export type ListOrgMembersResponseContent = {
  members: OrgMemberMap;
};

export type ListSpecialContractsResponseContent = {
  owned: ContractSummaryItem[];
  shared: ContractSummaryItem[];
};

export type ListUserOrganizationsResponseContent = {
  organizations: Org[];
};

export type Org = {
  orgId: string;
  name: string;
  type: string;
  primaryOwner: string;
  description?: string;
  website?: string;
  logoUrl?: string;
  billingEmail?: string;
  createdDate: string;
  memberCount?: number;
  userRole?: OrgRole;
  contractCount?: number;
  inviteCount?: number;
  roleCount?: number;
};

export type OrgCustomRole = {
  customRoleId: string;
  orgId: string;
  name: string;
  description?: string;
  permissions: OrgPermission[];
  createdDate: string;
  createdBy: string;
  memberCount?: number;
};

export type OrgCustomRoleMap = { [key: string]: OrgCustomRole };

export type OrgInvite = {
  inviteId: string;
  orgId: string;
  invitedEmail: string;
  role: OrgRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrgPermission[];
  invitedBy: string;
  invitedByProfile?: UserProfile;
  status: InviteStatus;
  createdDate: string;
  expiresDate?: string;
};

export type OrgInviteMap = { [key: string]: OrgInvite };

export type OrgMember = {
  userId: string;
  orgEmail: string;
  role: OrgRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrgPermission[];
  joinedDate: string;
  userProfile?: UserProfile;
};

export type OrgMemberMap = { [key: string]: OrgMember };

export type OrgTheme = {
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
};

export type PingResponseContent = {
  message: string;
};

export type PlainText = {
  text: string;
};

export type PresignedPostData = {
  url: string;
  fields: unknown;
};

export type ProcessingIncompleteErrorResponseContent = {
  message: string;
};

export type RemoveOrgMemberRequestContent = {
  orgId: string;
  userId: string;
};

export type RemoveOrgMemberResponseContent = {
  success: boolean;
};

export type ResendOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
  expiresDate?: string;
};

export type ResendOrgInviteResponseContent = {
  success: boolean;
  invite: OrgInvite;
};

export type ResourceNotFoundErrorResponseContent = {
  message: string;
};

export type ShareContractRequestContent = {
  contractId: string;
  emailsToAdd?: string[];
  emailsToRemove?: string[];
};

export type ShareContractResponseContent = {
  success: boolean;
  contractId: string;
  sharedWith: SharedUserDetails[];
  added?: string[];
  removed?: string[];
  invalidRemoves?: string[];
};

export type SharedUserDetails = {
  sharedWithUserId: string;
  sharedByUserId: string;
  sharedWithUserEmail: string;
  sharedTime: number;
};

export type SimpleTermDescription = {
  title: string;
  description: string;
};

export type TaggedText = {
  text: string;
};

export type TransferOrgOwnershipRequestContent = {
  orgId: string;
  newOwnerId: string;
};

export type TransferOrgOwnershipResponseContent = {
  success: boolean;
  org: Org;
};

export type UpdateContractRequestContent = {
  contractId: string;
  name: string;
};

export type UpdateContractResponseContent = {
  success: boolean;
};

export type UpdateOrgCustomRoleRequestContent = {
  orgId: string;
  customRoleId: string;
  name?: string;
  description?: string;
  permissions?: OrgPermission[];
};

export type UpdateOrgCustomRoleResponseContent = {
  success: boolean;
  customRole: OrgCustomRole;
};

export type UpdateOrgMemberRequestContent = {
  orgId: string;
  userId: string;
  role?: OrgRole;
  customRoleId?: string;
  orgEmail?: string;
};

export type UpdateOrgMemberResponseContent = {
  success: boolean;
  member: OrgMember;
};

export type UpdateOrgRequestContent = {
  orgId: string;
  name?: string;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type UpdateOrgResponseContent = {
  success: boolean;
  org: Org;
};

export type UpdateOrgThemeRequestContent = {
  orgId: string;
  theme: OrgTheme;
};

export type UpdateOrgThemeResponseContent = {
  success: boolean;
  theme: OrgTheme;
};

export type UpdateProfileRequestContent = {
  firstName?: string;
  lastName?: string;
  displayName?: string;
  accountType?: string;
  bio?: string;
  isOver18?: boolean;
};

export type UpdateProfileResponseContent = {
  success: boolean;
  message: string;
  userId: string;
  updatedFields?: string[];
};

export type UploadOrgPictureRequestContent = {
  orgId: string;
};

export type UploadOrgPictureResponseContent = {
  url_info: PresignedPostData;
};

export type UploadProfilePictureResponseContent = {
  url_info: PresignedPostData;
};

export type UserProfile = {
  userId?: string;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  email?: string;
  accountType?: string;
  bio?: string;
};

export type ValidationErrorResponseContent = {
  message: string;
};

// Re-export XML utilities
export * from './xml-types';
export * from './xml-utils';
