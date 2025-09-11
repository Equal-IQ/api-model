// Auto-generated index file with unwrapped types for main API
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

export enum IqModeSectionKey {
  earnings = "earnings",
  qualityOfRights = "qualityOfRights",
  usageObligations = "usageObligations",
  agreementLength = "agreementLength",
  liabilitySafeguards = "liabilitySafeguards"
}

// Unwrapped type definitions (no aliases)
export type AuthenticationErrorResponseContent = {
  message: string;
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

export type DeleteContractRequestContent = {
  contractId: string;
};

export type DeleteContractResponseContent = {
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
  type: ContractType;
  eqData?: EqModeData;
  iqData?: IqModeData;
  contractExtraction?: ContractExtractionResult;
  sharedWith?: string[];
  isOwner?: boolean;
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
  type: ContractType;
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

export type ListSpecialContractsResponseContent = {
  owned: ContractSummaryItem[];
  shared: ContractSummaryItem[];
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

export type UpdateContractRequestContent = {
  contractId: string;
  name: string;
};

export type UpdateContractResponseContent = {
  success: boolean;
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

export type ValidationErrorResponseContent = {
  message: string;
};
