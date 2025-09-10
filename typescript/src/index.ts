// Auto-generated index file with unwrapped types
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
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

export enum ContractType {
  recording = "recording",
  publishing = "publishing",
  management = "management",
  producer = "producer",
  services = "services",
  tbd = "tbd"
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

export enum InvitationStatus {
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

export enum OrganizationPermission {
  manage_members = "manage_members",
  manage_billing = "manage_billing",
  manage_settings = "manage_settings",
  view_all_contracts = "view_all_contracts",
  manage_contracts = "manage_contracts",
  invite_users = "invite_users",
  manage_roles = "manage_roles",
  view_analytics = "view_analytics"
}

export enum OrganizationRole {
  primary_owner = "primary_owner",
  admin = "admin",
  billing_admin = "billing_admin",
  member = "member",
  viewer = "viewer",
  custom = "custom"
}

export enum OrganizationType {
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
export type AuthenticationError = {
  message: string;
};

export type AuthenticationErrorResponseContent = {
  message: string;
};

export type CancelOrganizationInvitationInput = {
  organizationId: string;
  invitationId: string;
};

export type CancelOrganizationInvitationOutput = {
  success: boolean;
};

export type CancelOrganizationInvitationRequestContent = {
  organizationId: string;
  invitationId: string;
};

export type CancelOrganizationInvitationResponseContent = {
  success: boolean;
};

export type ContractAnalysisRecord = {
  contractId: string;
  name: string;
  type: ContractType;
  status: ContractStatus;
  uploadedOn: string;
  ownerId: string;
  eqCards?: EqModeData;
  iqData: IqModeData;
  extractedType?: ContractType;
  parties?: string[];
  terms?: ExtractionTermMap;
  variables?: ContractVariableMap;
  contractTexts?: ContractTexts;
  sharedUsers?: SharedUserDetails[];
  hasTTS?: boolean;
  isSpecial?: boolean;
};

export type ContractExtractionResult = {
  extractedType?: ContractType;
  parties?: string[];
  terms?: ExtractionTermMap;
  variables?: ContractVariableMap;
  contractTexts?: ContractTexts;
};

export type ContractMetadata = {
  contractId: string;
  name: string;
  type: ContractType;
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
  type: ContractType;
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

export type CreateCustomRoleInput = {
  organizationId: string;
  name: string;
  description?: string;
  permissions: OrganizationPermission[];
};

export type CreateCustomRoleOutput = {
  success: boolean;
  customRole: CustomRole;
};

export type CreateCustomRoleRequestContent = {
  organizationId: string;
  name: string;
  description?: string;
  permissions: OrganizationPermission[];
};

export type CreateCustomRoleResponseContent = {
  success: boolean;
  customRole: CustomRole;
};

export type CreateOrganizationInput = {
  name: string;
  type: OrganizationType;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type CreateOrganizationOutput = {
  success: boolean;
  organization: Organization;
};

export type CreateOrganizationRequestContent = {
  name: string;
  type: OrganizationType;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type CreateOrganizationResponseContent = {
  success: boolean;
  organization: Organization;
};

export type CustomRole = {
  customRoleId: string;
  organizationId: string;
  name: string;
  description?: string;
  permissions: OrganizationPermission[];
  createdDate: string;
  createdBy: string;
};

export type DeleteContractInput = {
  contractId: string;
};

export type DeleteContractOutput = {
  success: boolean;
};

export type DeleteContractRequestContent = {
  contractId: string;
};

export type DeleteContractResponseContent = {
  success: boolean;
};

export type DeleteCustomRoleInput = {
  organizationId: string;
  customRoleId: string;
};

export type DeleteCustomRoleOutput = {
  success: boolean;
};

export type DeleteCustomRoleRequestContent = {
  organizationId: string;
  customRoleId: string;
};

export type DeleteCustomRoleResponseContent = {
  success: boolean;
};

export type DeleteOrganizationInput = {
  organizationId: string;
};

export type DeleteOrganizationOutput = {
  success: boolean;
};

export type DeleteOrganizationRequestContent = {
  organizationId: string;
};

export type DeleteOrganizationResponseContent = {
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
};

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

export type ExposedTypes = {
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

export type GetContractInput = {
  contractId: string;
};

export type GetContractOutput = {
  contractId: string;
  ownerId: string;
  name: string;
  type: ContractType;
  eqData?: EqModeData;
  iqData?: IqModeData;
  contractExtraction?: ContractExtractionResult;
  sharedWith?: string[];
  isOwner?: boolean;
};

export type GetContractReadURLInput = {
  contractId: string;
};

export type GetContractReadURLOutput = {
  url: string;
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
  type: ContractType;
  eqData?: EqModeData;
  iqData?: IqModeData;
  contractExtraction?: ContractExtractionResult;
  sharedWith?: string[];
  isOwner?: boolean;
};

export type GetProfileInput = {
  userId?: string;
};

export type GetProfileOutput = {
  userId: string;
  profile: UserProfile;
};

export type GetProfilePictureInput = {
  userId?: string;
};

export type GetProfilePictureOutput = {
  profilePictureURL: string;
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

export type GetSpecialContractInput = {
  contractId: string;
};

export type GetSpecialContractOutput = {
  contractId: string;
  name: string;
  type: ContractType;
  eqmode: unknown;
  sections: unknown;
  isOwner: boolean;
  ownerId: string;
  sharedWith: string[];
};

export type GetSpecialContractRequestContent = {
  contractId: string;
};

export type GetSpecialContractResponseContent = {
  contractId: string;
  name: string;
  type: ContractType;
  eqmode: unknown;
  sections: unknown;
  isOwner: boolean;
  ownerId: string;
  sharedWith: string[];
};

export type GetUploadURLInput = {
  name: string;
};

export type GetUploadURLOutput = {
  url_info: PresignedPostData;
};

export type GetUploadURLRequestContent = {
  name: string;
};

export type GetUploadURLResponseContent = {
  url_info: PresignedPostData;
};

export type InternalServerError = {
  message: string;
};

export type InternalServerErrorResponseContent = {
  message: string;
};

export type InviteToOrganizationInput = {
  organizationId: string;
  emails: string[];
  role: OrganizationRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type InviteToOrganizationOutput = {
  success: boolean;
  invitations: OrganizationInvitation[];
  failedEmails?: string[];
};

export type InviteToOrganizationRequestContent = {
  organizationId: string;
  emails: string[];
  role: OrganizationRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type InviteToOrganizationResponseContent = {
  success: boolean;
  invitations: OrganizationInvitation[];
  failedEmails?: string[];
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

export type ListContractsInput = unknown;

export type ListContractsOutput = {
  owned?: ContractSummaryItem[];
  shared?: ContractSummaryItem[];
  contracts?: ContractMetadata[];
};

export type ListContractsResponseContent = {
  owned?: ContractSummaryItem[];
  shared?: ContractSummaryItem[];
  contracts?: ContractMetadata[];
};

export type ListOrganizationInvitationsInput = {
  organizationId: string;
  status?: InvitationStatus;
};

export type ListOrganizationInvitationsOutput = {
  invitations: OrganizationInvitation[];
};

export type ListOrganizationInvitationsRequestContent = {
  organizationId: string;
  status?: InvitationStatus;
};

export type ListOrganizationInvitationsResponseContent = {
  invitations: OrganizationInvitation[];
};

export type ListSpecialContractsInput = unknown;

export type ListSpecialContractsOutput = {
  owned: ContractSummaryItem[];
  shared: ContractSummaryItem[];
};

export type ListSpecialContractsResponseContent = {
  owned: ContractSummaryItem[];
  shared: ContractSummaryItem[];
};

export type Organization = {
  organizationId: string;
  name: string;
  type: OrganizationType;
  primaryOwner: string;
  description?: string;
  website?: string;
  billingEmail?: string;
  createdDate: string;
  memberCount?: number;
};

export type OrganizationInvitation = {
  invitationId: string;
  organizationId: string;
  invitedEmail: string;
  role: OrganizationRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrganizationPermission[];
  invitedBy: string;
  status: InvitationStatus;
  createdDate: string;
  expiresDate?: string;
  inviterProfile?: UserProfile;
};

export type OrganizationMember = {
  userId: string;
  organizationEmail: string;
  role: OrganizationRole;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrganizationPermission[];
  joinedDate: string;
  userProfile?: UserProfile;
};

export type PingInput = unknown;

export type PingOutput = {
  message: string;
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

export type ProcessingIncompleteError = {
  message: string;
};

export type ProcessingIncompleteErrorResponseContent = {
  message: string;
};

export type RemoveOrganizationMemberInput = {
  organizationId: string;
  userId: string;
};

export type RemoveOrganizationMemberOutput = {
  success: boolean;
};

export type RemoveOrganizationMemberRequestContent = {
  organizationId: string;
  userId: string;
};

export type RemoveOrganizationMemberResponseContent = {
  success: boolean;
};

export type ResendOrganizationInvitationInput = {
  organizationId: string;
  invitationId: string;
};

export type ResendOrganizationInvitationOutput = {
  success: boolean;
  invitation: OrganizationInvitation;
};

export type ResendOrganizationInvitationRequestContent = {
  organizationId: string;
  invitationId: string;
};

export type ResendOrganizationInvitationResponseContent = {
  success: boolean;
  invitation: OrganizationInvitation;
};

export type ResourceNotFoundError = {
  message: string;
};

export type ResourceNotFoundErrorResponseContent = {
  message: string;
};

export type ShareContractInput = {
  contractId: string;
  emailsToAdd?: string[];
  emailsToRemove?: string[];
};

export type ShareContractOutput = {
  success: boolean;
  contractId: string;
  sharedWith: SharedUserDetails[];
  added?: string[];
  removed?: string[];
  invalidRemoves?: string[];
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

export type TransferOrganizationOwnershipInput = {
  organizationId: string;
  newOwnerId: string;
};

export type TransferOrganizationOwnershipOutput = {
  success: boolean;
  organization: Organization;
};

export type TransferOrganizationOwnershipRequestContent = {
  organizationId: string;
  newOwnerId: string;
};

export type TransferOrganizationOwnershipResponseContent = {
  success: boolean;
  organization: Organization;
};

export type UpdateContractInput = {
  contractId: string;
  name: string;
};

export type UpdateContractOutput = {
  success: boolean;
};

export type UpdateContractRequestContent = {
  contractId: string;
  name: string;
};

export type UpdateContractResponseContent = {
  success: boolean;
};

export type UpdateCustomRoleInput = {
  organizationId: string;
  customRoleId: string;
  name?: string;
  description?: string;
  permissions?: OrganizationPermission[];
};

export type UpdateCustomRoleOutput = {
  success: boolean;
  customRole: CustomRole;
};

export type UpdateCustomRoleRequestContent = {
  organizationId: string;
  customRoleId: string;
  name?: string;
  description?: string;
  permissions?: OrganizationPermission[];
};

export type UpdateCustomRoleResponseContent = {
  success: boolean;
  customRole: CustomRole;
};

export type UpdateOrganizationInput = {
  organizationId: string;
  name?: string;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type UpdateOrganizationMemberInput = {
  organizationId: string;
  userId: string;
  role?: OrganizationRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type UpdateOrganizationMemberOutput = {
  success: boolean;
  member: OrganizationMember;
};

export type UpdateOrganizationMemberRequestContent = {
  organizationId: string;
  userId: string;
  role?: OrganizationRole;
  customRoleId?: string;
  organizationEmail?: string;
};

export type UpdateOrganizationMemberResponseContent = {
  success: boolean;
  member: OrganizationMember;
};

export type UpdateOrganizationOutput = {
  success: boolean;
  organization: Organization;
};

export type UpdateOrganizationRequestContent = {
  organizationId: string;
  name?: string;
  description?: string;
  website?: string;
  billingEmail?: string;
};

export type UpdateOrganizationResponseContent = {
  success: boolean;
  organization: Organization;
};

export type UpdateProfileInput = {
  firstName?: string;
  lastName?: string;
  displayName?: string;
  accountType?: AccountType;
  bio?: string;
  isOver18?: boolean;
};

export type UpdateProfileOutput = {
  success: boolean;
  message: string;
  userId: string;
  updatedFields?: string[];
};

export type UpdateProfileRequestContent = {
  firstName?: string;
  lastName?: string;
  displayName?: string;
  accountType?: AccountType;
  bio?: string;
  isOver18?: boolean;
};

export type UpdateProfileResponseContent = {
  success: boolean;
  message: string;
  userId: string;
  updatedFields?: string[];
};

export type UploadProfilePictureInput = unknown;

export type UploadProfilePictureOutput = {
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
  accountType?: AccountType;
  bio?: string;
};

export type ValidationError = {
  message: string;
};

export type ValidationErrorResponseContent = {
  message: string;
};
