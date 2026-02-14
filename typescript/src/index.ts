// Auto-generated index file with unwrapped types
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
export type Schemas = components['schemas'];

// Export XML utilities (manually maintained)
export * from './xml-types';
export * from './xml-utils';

// Unwrapped enum definitions
export enum AuditOperation {
  insert = "insert",
  update = "update",
  delete = "delete",
  access = "access",
  export = "export",
  share = "share"
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

export enum ContractVariableType {
  eq_term = "eq_term",
  discovered_term = "discovered_term",
  external_term = "external_term",
  internal_citation = "internal_citation"
}

export enum DealPermission {
  view_deal = "view_deal",
  edit_deal = "edit_deal",
  delete_deal = "delete_deal",
  manage_access = "manage_access",
  approve_deal = "approve_deal",
  create_version = "create_version",
  view_ai_analysis = "view_ai_analysis",
  view_revision_history = "view_revision_history",
  export_deal = "export_deal",
  manage_deliverables = "manage_deliverables",
  comment_deal = "comment_deal",
  view_financial = "view_financial",
  edit_financial = "edit_financial"
}

export enum DealStage {
  drafting = "drafting",
  negotiation = "negotiation",
  signing = "signing",
  delivery = "delivery",
  completed = "completed",
  cancelled = "cancelled"
}

export enum DeliverableSource {
  inferred = "inferred",
  template = "template",
  imported = "imported",
  manual = "manual"
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
  a = "a",
  b = "b"
}

export enum FilePermission {
  view_file = "view_file",
  edit_file = "edit_file",
  delete_file = "delete_file",
  share_file = "share_file",
  manage_access = "manage_access",
  comment_file = "comment_file",
  export_file = "export_file",
  rename_file = "rename_file"
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
  invite_users = "invite_users",
  manage_roles = "manage_roles",
  view_analytics = "view_analytics",
  view_audit_logs = "view_audit_logs"
}

export enum RecordType {
  normal = "normal",
  meta_audit = "meta_audit",
  unknown = "unknown",
  cleanup = "cleanup",
  export = "export",
  system = "system"
}

export enum StatisticGrouping {
  hour = "hour",
  day = "day",
  week = "week",
  month = "month"
}

// Unwrapped type definitions (no aliases)
export type AcceptOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
};

export type AcceptOrgInviteResponseContent = {
  organization: Org;
  member: OrgMember;
};

export type AuditLog = {
  auditLogId: string;
  tableName: string;
  recordType: RecordType;
  operation: AuditOperation;
  fieldName?: string;
  oldValue?: unknown;
  newValue?: unknown;
  changedBy: string;
  changedAt: string;
  metadata?: unknown;
};

export type AuditLogMap = { [key: string]: AuditLog };

export type AuditStatistics = {
  totalEvents: number;
  byTable?: unknown;
  byOperation?: unknown;
  topUsers?: unknown;
};

export type AuthenticationErrorResponseContent = {
  message: string;
};

export type CancelOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
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
  sharedUsers?: SharedUserDetailsMap;
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
  ownerOrgId?: string;
  sharedUsers?: SharedUserDetailsMap;
  isOwner?: boolean;
  hasTTS?: boolean;
  isSpecial?: boolean;
};

export type ContractMetadataMap = { [key: string]: ContractMetadata };

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

export type ContractSummaryMap = { [key: string]: ContractSummaryItem };

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

export type CreateDealRequestContent = {
  orgId: string;
  title: string;
  description?: string;
  initialStage?: DealStage;
  metadata?: unknown;
};

export type CreateDealResponseContent = {
  deal: Deal;
  initialVersion: DealVersion;
};

export type CreateDealVersionRequestContent = {
  dealId: string;
  stage: DealStage;
  changeReason: string;
  metadata?: unknown;
};

export type CreateDealVersionResponseContent = {
  version: DealVersion;
};

export type CreateDeliverableRequestContent = {
  dealId: string;
  versionId: string;
  description: string;
  source?: DeliverableSource;
  dueDate?: string;
  assignedTo?: string;
  status?: string;
};

export type CreateDeliverableResponseContent = {
  deliverable: Deliverable;
};

export type CreateFileRequestContent = {
  orgId: string;
  fileName: string;
  sizeBytes: number;
  fileType?: string;
  folderPath?: string;
  tags?: string[];
  dealId?: string;
  dealVersionId?: string;
  requestUploadUrl?: boolean;
};

export type CreateFileResponseContent = {
  file: File;
  uploadUrl?: PresignedUrl;
};

export type CreateOrgCustomRoleRequestContent = {
  orgId: string;
  name: string;
  description?: string;
  permissions: OrgPermission[];
};

export type CreateOrgCustomRoleResponseContent = {
  customRole: OrgCustomRole;
};

export type CreateOrgInviteRequestContent = {
  orgId: string;
  emails: string[];
  role: string;
  customRoleId?: string;
  orgEmail?: string;
};

export type CreateOrgInviteResponseContent = {
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
  org: Org;
};

export type Deal = {
  dealId: string;
  ownerUserId: string;
  ownerOrgId?: string;
  parentDealId?: string;
  createdByUserId: string;
  updatedByUserId?: string;
  createdAt: string;
  updatedAt: string;
};

export type DealAccess = {
  dealAccessId: string;
  dealId: string;
  grantedToOrgId: string;
  grantedToUserId?: string;
  grantedByUserId: string;
  grantedAt: string;
  expiresAt?: string;
  partyRole?: string;
  permissions: DealPermission[];
  grantablePermissions?: DealPermission[];
  isDeny?: boolean;
  revokedByUserId?: string;
  revokedAt?: string;
  revocationReason?: string;
  metadata?: unknown;
  createdAt: string;
  updatedAt: string;
};

export type DealAccessMap = { [key: string]: DealAccess };

export type DealMap = { [key: string]: Deal };

export type DealVersion = {
  dealVersionId: string;
  dealId: string;
  versionNumber: number;
  stage: DealStage;
  content: unknown;
  metadata?: unknown;
  createdByUserId: string;
  approvedByUserId?: string;
  createdAt: string;
  approvedAt?: string;
};

export type DealVersionMap = { [key: string]: DealVersion };

export type DeclineOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
};

export type DeleteContractRequestContent = {
  contractId: string;
};

export type DeleteContractResponseContent = {
  success: boolean;
};

export type DeleteDealRequestContent = {
  dealId: string;
  hardDelete?: boolean;
};

export type DeleteFileRequestContent = {
  fileId: string;
  hardDelete?: boolean;
};

export type DeleteOrgCustomRoleRequestContent = {
  orgId: string;
  customRoleId: string;
};

export type DeleteOrgRequestContent = {
  orgId: string;
};

export type Deliverable = {
  deliverableId: string;
  dealVersionId: string;
  name: string;
  description?: string;
  source?: DeliverableSource;
  status?: string;
  assignedToUserId?: string;
  responsibleOrgId?: string;
  dueDate?: string;
  completedDate?: string;
  metadata?: unknown;
  createdByUserId: string;
  updatedByUserId?: string;
  createdAt: string;
  updatedAt: string;
};

export type DeliverableMap = { [key: string]: Deliverable };

export type EmptyStructure = unknown;

export type EqCardUniqueData = {
  moneyYouReceive: EqMoneyCard;
} | {
  whatYouOwn: EqOwnershipCard;
} | {
  whatYoureResponsibleFor: EqResponsibilitiesCard;
} | {
  howLongThisDealLasts: EqDurationCard;
} | {
  risksCostsLegalStuff: EqLegalCard;
} | {
  empty: EmptyStructure;
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

export type File = {
  fileId: string;
  ownerUserId: string;
  ownerOrgId?: string;
  createdByUserId: string;
  fileName: string;
  sizeBytes: number;
  fileType: string;
  description?: string;
  dealId?: string;
  dealVersionId?: string;
  metadata?: unknown;
  updatedByUserId?: string;
  createdAt: string;
  updatedAt: string;
};

export type FileAccess = {
  fileAccessId: string;
  fileId: string;
  grantedToOrgId: string;
  grantedToUserId?: string;
  grantedByUserId: string;
  grantedAt: string;
  expiresAt?: string;
  permissions: FilePermission[];
  grantablePermissions?: FilePermission[];
  isDeny?: boolean;
  revokedByUserId?: string;
  revokedAt?: string;
  revocationReason?: string;
  metadata?: unknown;
  createdAt: string;
  updatedAt: string;
};

export type FileAccessMap = { [key: string]: FileAccess };

export type FileMap = { [key: string]: File };

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

export type GenerateDownloadUrlRequestContent = {
  fileId: string;
  expirationSeconds?: number;
  disposition?: string;
  downloadFileName?: string;
};

export type GenerateDownloadUrlResponseContent = {
  downloadUrl: PresignedUrl;
};

export type GenerateUploadUrlRequestContent = {
  fileId: string;
  contentType?: string;
  expirationSeconds?: number;
};

export type GenerateUploadUrlResponseContent = {
  uploadUrl: PresignedUrl;
};

export type GetAuditLogRequestContent = {
  logId: string;
};

export type GetAuditLogResponseContent = {
  auditLog: AuditLog;
};

export type GetAuditStatisticsRequestContent = {
  tableName?: string;
  startDate: string;
  endDate: string;
  groupBy?: StatisticGrouping;
};

export type GetAuditStatisticsResponseContent = {
  statistics: AuditStatistics;
  timeSeries?: TimeSeriesPoint[];
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
  ownerOrgId?: string;
  name: string;
  type: string;
  eqData?: EqModeData;
  iqData?: IqModeData;
  contractExtraction?: ContractExtractionResult;
  sharedWith?: string[];
  isOwner?: boolean;
};

export type GetDealRequestContent = {
  dealId: string;
  includeVersions?: boolean;
  includeDeliverables?: boolean;
  includeAccess?: boolean;
};

export type GetDealResponseContent = {
  deal: Deal;
  versions?: DealVersionMap;
  deliverables?: DeliverableMap;
  access?: DealAccessMap;
};

export type GetDealVersionRequestContent = {
  dealId: string;
  versionId: string;
  includeDeliverables?: boolean;
};

export type GetDealVersionResponseContent = {
  version: DealVersion;
  deliverables?: DeliverableMap;
};

export type GetFileRequestContent = {
  fileId: string;
  includeAccess?: boolean;
  requestDownloadUrl?: boolean;
};

export type GetFileResponseContent = {
  file: File;
  access?: FileAccessMap;
  downloadUrl?: PresignedUrl;
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
  userId: string;
};

export type GetProfilePictureResponseContent = {
  profilePictureURL: string;
};

export type GetProfileRequestContent = {
  userId?: string;
};

export type GetProfileResponseContent = {
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
  orgId?: string;
};

export type GetUploadURLResponseContent = {
  url_info: PresignedPostData;
};

export type GrantDealAccessRequestContent = {
  dealId: string;
  grantToOrgId: string;
  grantToUserId?: string;
  permissions: DealPermission[];
  partyRole?: string;
  expiresAt?: string;
  grantablePermissions?: DealPermission[];
  isDeny?: boolean;
};

export type GrantDealAccessResponseContent = {
  access: DealAccess;
};

export type GrantFileAccessRequestContent = {
  fileId: string;
  grantToOrgId: string;
  grantToUserId?: string;
  permissions: FilePermission[];
  expiresAt?: string;
  grantablePermissions?: FilePermission[];
  isDeny?: boolean;
};

export type GrantFileAccessResponseContent = {
  access: FileAccess;
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

export type ListAuditLogsRequestContent = {
  tableName?: string;
  recordType?: RecordType;
  operation?: AuditOperation;
  changedBy?: string;
  startDate?: string;
  endDate?: string;
  fieldName?: string;
  nextToken?: string;
  limit?: number;
};

export type ListAuditLogsResponseContent = {
  logs: AuditLogMap;
  nextToken?: string;
};

export type ListContractsRequestContent = {
  orgId?: string;
};

export type ListContractsResponseContent = {
  owned?: ContractSummaryMap;
  shared?: ContractSummaryMap;
  contracts?: ContractMetadataMap;
};

export type ListDealAccessRequestContent = {
  dealId: string;
  orgId?: string;
  includeRevoked?: boolean;
  includeExpired?: boolean;
  nextToken?: string;
  limit?: number;
};

export type ListDealAccessResponseContent = {
  access: DealAccessMap;
  nextToken?: string;
};

export type ListDealVersionsRequestContent = {
  dealId: string;
  stage?: DealStage;
  nextToken?: string;
  limit?: number;
};

export type ListDealVersionsResponseContent = {
  versions: DealVersionMap;
  nextToken?: string;
};

export type ListDealsRequestContent = {
  orgId?: string;
  stage?: DealStage;
  createdBy?: string;
  nextToken?: string;
  limit?: number;
};

export type ListDealsResponseContent = {
  deals: DealMap;
  nextToken?: string;
};

export type ListDeliverablesRequestContent = {
  dealId: string;
  versionId?: string;
  status?: string;
  assignedTo?: string;
  nextToken?: string;
  limit?: number;
};

export type ListDeliverablesResponseContent = {
  deliverables: DeliverableMap;
  nextToken?: string;
};

export type ListFileAccessRequestContent = {
  fileId: string;
  orgId?: string;
  includeRevoked?: boolean;
  includeExpired?: boolean;
  nextToken?: string;
  limit?: number;
};

export type ListFileAccessResponseContent = {
  access: FileAccessMap;
  nextToken?: string;
};

export type ListFilesRequestContent = {
  orgId?: string;
  dealId?: string;
  dealVersionId?: string;
  folderPath?: string;
  tags?: string[];
  uploadedBy?: string;
  includeDeleted?: boolean;
  nextToken?: string;
  limit?: number;
};

export type ListFilesResponseContent = {
  files: FileMap;
  nextToken?: string;
  totalSizeBytes?: number;
};

export type ListOrgCustomRolesRequestContent = {
  orgId: string;
  nextToken?: string;
  limit?: number;
};

export type ListOrgCustomRolesResponseContent = {
  roles: OrgCustomRoleMap;
  nextToken?: string;
};

export type ListOrgInvitesRequestContent = {
  orgId: string;
  status?: InviteStatus;
  nextToken?: string;
  limit?: number;
};

export type ListOrgInvitesResponseContent = {
  invites: OrgInviteMap;
  nextToken?: string;
};

export type ListOrgMembersRequestContent = {
  orgId: string;
  role?: string;
  includeInactive?: boolean;
  nextToken?: string;
  limit?: number;
};

export type ListOrgMembersResponseContent = {
  members: OrgMemberMap;
  nextToken?: string;
};

export type ListSpecialContractsResponseContent = {
  owned: ContractSummaryMap;
  shared: ContractSummaryMap;
};

export type ListUserOrganizationsRequestContent = {
  nextToken?: string;
  limit?: number;
};

export type ListUserOrganizationsResponseContent = {
  organizations: OrgMap;
  nextToken?: string;
};

export type Org = {
  orgId: string;
  name: string;
  type: string;
  primaryOwnerId: string;
  description?: string;
  website?: string;
  logoUrl?: string;
  billingEmail?: string;
  metadata?: unknown;
  createdAt: string;
  updatedAt: string;
  memberCount?: number;
  userRole?: string;
  dealCount?: number;
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
  orgInviteId: string;
  orgId: string;
  invitedEmail: string;
  role: string;
  customRoleId?: string;
  customRoleName?: string;
  customPermissions?: OrgPermission[];
  invitedByUserId: string;
  invitedByProfile?: UserProfile;
  status: InviteStatus;
  createdAt: string;
  updatedAt: string;
  expiresAt?: string;
  acceptedAt?: string;
};

export type OrgInviteMap = { [key: string]: OrgInvite };

export type OrgMap = { [key: string]: Org };

export type OrgMember = {
  userId: string;
  orgEmail: string;
  role: string;
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

export type PresignedUrl = {
  url: string;
  expiresAt: string;
  method?: string;
  headers?: unknown;
};

export type ProcessingIncompleteErrorResponseContent = {
  message: string;
};

export type RemoveOrgMemberRequestContent = {
  orgId: string;
  userId: string;
};

export type ResendOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
  expiresDate?: string;
};

export type ResendOrgInviteResponseContent = {
  invite: OrgInvite;
};

export type ResourceNotFoundErrorResponseContent = {
  message: string;
};

export type RevokeDealAccessRequestContent = {
  dealId: string;
  accessId: string;
  reason: string;
};

export type RevokeFileAccessRequestContent = {
  fileId: string;
  accessId: string;
  reason: string;
};

export type ShareContractRequestContent = {
  contractId: string;
  emailsToAdd?: string[];
  emailsToRemove?: string[];
};

export type ShareContractResponseContent = {
  success: boolean;
  contractId: string;
  sharedWith: SharedUserDetailsMap;
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

export type SharedUserDetailsMap = { [key: string]: SharedUserDetails };

export type SimpleTermDescription = {
  title: string;
  description: string;
};

export type TaggedText = {
  text: string;
};

export type TimeSeriesPoint = {
  timestamp: string;
  count: number;
  metrics?: unknown;
};

export type TransferOrgOwnershipRequestContent = {
  orgId: string;
  newOwnerId: string;
};

export type TransferOrgOwnershipResponseContent = {
  org: Org;
};

export type UpdateContractRequestContent = {
  contractId: string;
  name: string;
};

export type UpdateContractResponseContent = {
  success: boolean;
};

export type UpdateDealAccessRequestContent = {
  dealId: string;
  accessId: string;
  permissions?: DealPermission[];
  grantablePermissions?: DealPermission[];
  partyRole?: string;
  expiresAt?: string;
  isDeny?: boolean;
};

export type UpdateDealAccessResponseContent = {
  access: DealAccess;
};

export type UpdateDealRequestContent = {
  dealId: string;
  title?: string;
  description?: string;
  newStage?: DealStage;
  changeReason?: string;
  metadata?: unknown;
};

export type UpdateDealResponseContent = {
  deal: Deal;
  newVersion?: DealVersion;
};

export type UpdateDeliverableRequestContent = {
  dealId: string;
  deliverableId: string;
  description?: string;
  source?: DeliverableSource;
  dueDate?: string;
  assignedTo?: string;
  status?: string;
};

export type UpdateDeliverableResponseContent = {
  deliverable: Deliverable;
};

export type UpdateFileAccessRequestContent = {
  fileId: string;
  accessId: string;
  permissions?: FilePermission[];
  grantablePermissions?: FilePermission[];
  expiresAt?: string;
  isDeny?: boolean;
};

export type UpdateFileAccessResponseContent = {
  access: FileAccess;
};

export type UpdateFileRequestContent = {
  fileId: string;
  fileName?: string;
  folderPath?: string;
  tags?: string[];
  dealId?: string;
  dealVersionId?: string;
};

export type UpdateFileResponseContent = {
  file: File;
};

export type UpdateOrgCustomRoleRequestContent = {
  orgId: string;
  customRoleId: string;
  name?: string;
  description?: string;
  permissions?: OrgPermission[];
};

export type UpdateOrgCustomRoleResponseContent = {
  customRole: OrgCustomRole;
};

export type UpdateOrgMemberRequestContent = {
  orgId: string;
  userId: string;
  role?: string;
  customRoleId?: string;
  orgEmail?: string;
};

export type UpdateOrgMemberResponseContent = {
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
  org: Org;
};

export type UpdateOrgThemeRequestContent = {
  orgId: string;
  theme: OrgTheme;
};

export type UpdateOrgThemeResponseContent = {
  theme: OrgTheme;
};

export type UpdateProfileRequestContent = {
  userId: string;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  accountType?: string;
  bio?: string;
  isOver18?: boolean;
};

export type UpdateProfileResponseContent = {
  profile: UserProfile;
};

export type UploadOrgPictureRequestContent = {
  orgId: string;
};

export type UploadOrgPictureResponseContent = {
  urlInfo: PresignedPostData;
};

export type UploadProfilePictureRequestContent = {
  userId: string;
};

export type UploadProfilePictureResponseContent = {
  urlInfo: PresignedPostData;
};

export type UserProfile = {
  userId: string;
  firstName: string;
  lastName: string;
  displayName?: string;
  email: string;
  accountType?: string;
  bio?: string;
};

export type ValidationErrorResponseContent = {
  message: string;
};
