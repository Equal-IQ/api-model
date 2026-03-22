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

export enum CitationSourceType {
  legal_kb = "legal_kb",
  app_kb = "app_kb",
  user_document = "user_document",
  deal_analysis = "deal_analysis",
  external = "external"
}

export enum ContentDisposition {
  inline = "inline",
  attachment = "attachment"
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

export enum DeliverableStatus {
  incomplete = "incomplete",
  in_progress = "in_progress",
  overdue = "overdue",
  complete = "complete"
}

export enum DiffOperationType {
  insert = "insert",
  delete = "delete",
  replace = "replace"
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

export enum MessageRole {
  user = "user",
  assistant = "assistant"
}

export enum OrgMemberFilter {
  active = "active",
  inactive = "inactive"
}

export enum OrgPermission {
  manage_members = "manage_members",
  manage_billing = "manage_billing",
  manage_settings = "manage_settings",
  invite_users = "invite_users",
  manage_roles = "manage_roles",
  view_analytics = "view_analytics",
  view_audit_logs = "view_audit_logs",
  view_all_deals = "view_all_deals",
  view_all_files = "view_all_files"
}

export enum RecordType {
  normal = "normal",
  meta_audit = "meta_audit",
  unknown = "unknown",
  cleanup = "cleanup",
  export = "export",
  system = "system"
}

export enum RevisionStatus {
  pending = "pending",
  applied = "applied",
  rejected = "rejected",
  failed = "failed"
}

export enum RiskLevel {
  low = "low",
  medium = "medium",
  high = "high"
}

export enum RunStatus {
  in_progress = "in_progress",
  complete = "complete",
  failed = "failed",
  cancelled = "cancelled"
}

export enum StatisticGrouping {
  hour = "hour",
  day = "day",
  week = "week",
  month = "month"
}

export enum StepMode {
  quick_response = "quick_response",
  full_cycle = "full_cycle"
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

export type ApplyRevisionRequestContent = {
  revisionId: string;
};

export type ApplyRevisionResponseContent = {
  revision: Revision;
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

export type CancelRunRequestContent = {
  runId: string;
};

export type CancelRunResponseContent = {
  run: Run;
};

export type CharacterRange = {
  start: number;
  end: number;
};

export type Citation = {
  id: string;
  sourceType: CitationSourceType;
  sourceId: string;
  sourceName: string;
  excerpt?: string;
  location?: string;
  siteReference?: string;
  url?: string;
};

export type Conversation = {
  conversationId: string;
  dealId: string;
  selectedContexts?: SelectedContext;
  title?: string;
  createdByUserId: string;
  updatedByUserId?: string;
  createdAt: string;
  updatedAt: string;
};

export type CreateConversationRequestContent = {
  selectedContexts: SelectedContext;
  initialMessage: string;
  title?: string;
};

export type CreateConversationResponseContent = {
  sendMessageOutput?: SendMessageOutput;
};

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
  dealVersionId: string;
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
  dealIds?: string[];
  dealVersionIds?: string[];
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
  fileIds?: string[];
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

export type DealContext = {
  dealIds: string[];
};

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
  fileIds?: string[];
  createdAt: string;
  approvedAt?: string;
};

export type DealVersionMap = { [key: string]: DealVersion };

export type DeclineOrgInviteRequestContent = {
  orgId: string;
  inviteId: string;
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
  status?: DeliverableStatus;
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

export type DiffImpact = {
  riskLevel: RiskLevel;
  affectedParties: string[];
  relatedClauses?: string[];
};

export type DiffLocation = {
  section?: string;
  clauseId?: string;
  path?: string;
  range?: CharacterRange;
  lineRange?: LineRange;
  context?: string;
};

export type DiffOperation = {
  id: string;
  dealVersionId: string;
  type: DiffOperationType;
  oldText: string;
  newText: string;
  reason: string;
  legalRationale?: string;
  location: DiffLocation;
  validation: DiffValidation;
  impact: DiffImpact;
  preview: DiffPreview;
};

export type DiffPreview = {
  before: string;
  after: string;
  highlighted: boolean;
};

export type DiffValidation = {
  textFound: boolean;
  multipleMatches?: number;
  matchLocations?: CharacterRange[];
};

export type File = {
  fileId: string;
  ownerUserId: string;
  ownerOrgId?: string;
  createdByUserId: string;
  fileName: string;
  sizeBytes: number;
  fileType: string;
  description?: string;
  dealIds?: string[];
  dealVersionIds?: string[];
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

export type FileContext = {
  fileIds: string[];
};

export type FileMap = { [key: string]: File };

export type GenerateDownloadUrlRequestContent = {
  fileId: string;
  expirationSeconds?: number;
  disposition?: ContentDisposition;
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
  auditLogId: string;
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

export type GetConversationRequestContent = {
  conversationId: string;
};

export type GetConversationResponseContent = {
  conversation: Conversation;
  messages: MessageMap;
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
  dealVersionId: string;
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

export type GetRunRequestContent = {
  runId: string;
};

export type GetRunResponseContent = {
  run: Run;
};

export type GlobalContext = {
  isEnabled: boolean;
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

export type LineRange = {
  startLine: number;
  endLine: number;
  startColumn?: number;
  endColumn?: number;
};

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
  dealVersionId?: string;
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
  filters?: OrgMemberFilter[];
  nextToken?: string;
  limit?: number;
};

export type ListOrgMembersResponseContent = {
  members: OrgMemberMap;
  nextToken?: string;
};

export type ListRunRevisionsRequestContent = {
  runId: string;
};

export type ListRunRevisionsResponseContent = {
  revisions: RevisionMap;
};

export type ListUserOrganizationsRequestContent = {
  nextToken?: string;
  limit?: number;
};

export type ListUserOrganizationsResponseContent = {
  organizations: OrgMap;
  nextToken?: string;
};

export type Message = {
  runId: string;
  messageId: string;
  conversationId: string;
  role: MessageRole;
  content: string;
  citations?: Citation[];
  timestamp: string;
};

export type MessageMap = { [key: string]: Message };

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
  createdByUserId: string;
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

export type RejectRevisionRequestContent = {
  revisionId: string;
};

export type RejectRevisionResponseContent = {
  revision: Revision;
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

export type Revision = {
  revisionId: string;
  runId: string;
  stepId: string;
  diff: DiffOperation;
  status: RevisionStatus;
  createdAt: string;
  appliedAt?: string;
};

export type RevisionMap = { [key: string]: Revision };

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

export type Run = {
  runId: string;
  conversationId: string;
  userMessageId: string;
  status: RunStatus;
  currentStep: number;
  selectedContexts: SelectedContext;
  thoughtDescription?: string;
  responseMessage?: Message;
  errorMessage?: string;
  steps?: StepAuditRecordMap;
};

export type SelectedContext = {
  file: FileContext;
} | {
  deal: DealContext;
} | {
  global: GlobalContext;
};

export type SendMessageOutput = {
  conversationId: string;
  runId: string;
};

export type SendMessageRequestContent = {
  conversationId: string;
  message: string;
  selectedContexts?: SelectedContext;
};

export type SendMessageResponseContent = {
  conversationId: string;
  runId: string;
};

export type StepAuditRecord = {
  runStepId: string;
  runId: string;
  stepNumber: number;
  mode: StepMode;
  reasoning?: string;
  toolCalls?: unknown;
  toolResults?: unknown;
  statusMessage?: string;
  durationMs: number;
  timestamp: string;
};

export type StepAuditRecordMap = { [key: string]: StepAuditRecord };

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
  dealIds?: string[];
  dealVersionIds?: string[];
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
