// Auto-generated index file
// Export all schemas from the OpenAPI specification
export * from './models';
export { components } from './models';

// Re-export schemas as top-level types for easier importing
import { components } from './models';
export type Schemas = components['schemas'];

// Make each schema available as a top-level export
type SchemaNames = keyof components['schemas'];
type ExtractSchema<K extends SchemaNames> = components['schemas'][K];

export type AuthenticationErrorResponseContent = ExtractSchema<'AuthenticationErrorResponseContent'>
export type ContractExtractionResult = ExtractSchema<'ContractExtractionResult'>
export type ContractMarkupResult = ExtractSchema<'ContractMarkupResult'>
export type ContractMetadata = ExtractSchema<'ContractMetadata'>
export type ContractSummaryItem = ExtractSchema<'ContractSummaryItem'>
export type ContractVariable = ExtractSchema<'ContractVariable'>
export type ContractVariableMap = ExtractSchema<'ContractVariableMap'>
export type DeleteContractRequestContent = ExtractSchema<'DeleteContractRequestContent'>
export type DeleteContractResponseContent = ExtractSchema<'DeleteContractResponseContent'>
export type EmptyStructure = ExtractSchema<'EmptyStructure'>
export type EqCardUniqueData = ExtractSchema<'EqCardUniqueData'>
export type EqDurationCard = ExtractSchema<'EqDurationCard'>
export type EqLegalCard = ExtractSchema<'EqLegalCard'>
export type EqModeCard = ExtractSchema<'EqModeCard'>
export type EqModeCardMap = ExtractSchema<'EqModeCardMap'>
export type EqModeData = ExtractSchema<'EqModeData'>
export type EqModeItem = ExtractSchema<'EqModeItem'>
export type EqMoneyCard = ExtractSchema<'EqMoneyCard'>
export type EqOwnershipCard = ExtractSchema<'EqOwnershipCard'>
export type EqResponsibilitesCard = ExtractSchema<'EqResponsibilitesCard'>
export type ExtractionTerm = ExtractSchema<'ExtractionTerm'>
export type ExtractionTermMap = ExtractSchema<'ExtractionTermMap'>
export type FixedTermValue = ExtractSchema<'FixedTermValue'>
export type FixedValueTermInference = ExtractSchema<'FixedValueTermInference'>
export type GetContractReadURLRequestContent = ExtractSchema<'GetContractReadURLRequestContent'>
export type GetContractReadURLResponseContent = ExtractSchema<'GetContractReadURLResponseContent'>
export type GetContractRequestContent = ExtractSchema<'GetContractRequestContent'>
export type GetContractResponseContent = ExtractSchema<'GetContractResponseContent'>
export type GetProfilePictureRequestContent = ExtractSchema<'GetProfilePictureRequestContent'>
export type GetProfilePictureResponseContent = ExtractSchema<'GetProfilePictureResponseContent'>
export type GetProfileRequestContent = ExtractSchema<'GetProfileRequestContent'>
export type GetProfileResponseContent = ExtractSchema<'GetProfileResponseContent'>
export type GetSpecialContractRequestContent = ExtractSchema<'GetSpecialContractRequestContent'>
export type GetSpecialContractResponseContent = ExtractSchema<'GetSpecialContractResponseContent'>
export type GetTTSURLsRequestContent = ExtractSchema<'GetTTSURLsRequestContent'>
export type GetTTSURLsResponseContent = ExtractSchema<'GetTTSURLsResponseContent'>
export type GetUploadURLRequestContent = ExtractSchema<'GetUploadURLRequestContent'>
export type GetUploadURLResponseContent = ExtractSchema<'GetUploadURLResponseContent'>
export type InternalServerErrorResponseContent = ExtractSchema<'InternalServerErrorResponseContent'>
export type IqModeData = ExtractSchema<'IqModeData'>
export type IqModePerspective = ExtractSchema<'IqModePerspective'>
export type IqModePerspectiveMap = ExtractSchema<'IqModePerspectiveMap'>
export type IqModeQuestion = ExtractSchema<'IqModeQuestion'>
export type IqModeSection = ExtractSchema<'IqModeSection'>
export type IqModeSectionMap = ExtractSchema<'IqModeSectionMap'>
export type ListContractsResponseContent = ExtractSchema<'ListContractsResponseContent'>
export type ListSpecialContractsResponseContent = ExtractSchema<'ListSpecialContractsResponseContent'>
export type MarkupStatistics = ExtractSchema<'MarkupStatistics'>
export type PingResponseContent = ExtractSchema<'PingResponseContent'>
export type PresignedPostData = ExtractSchema<'PresignedPostData'>
export type ProcessingIncompleteErrorResponseContent = ExtractSchema<'ProcessingIncompleteErrorResponseContent'>
export type ResourceNotFoundErrorResponseContent = ExtractSchema<'ResourceNotFoundErrorResponseContent'>
export type ShareContractRequestContent = ExtractSchema<'ShareContractRequestContent'>
export type ShareContractResponseContent = ExtractSchema<'ShareContractResponseContent'>
export type SharedUserDetails = ExtractSchema<'SharedUserDetails'>
export type SimpleTermDescription = ExtractSchema<'SimpleTermDescription'>
export type TTSPresignedUrlMap = ExtractSchema<'TTSPresignedUrlMap'>
export type TaggedText = ExtractSchema<'TaggedText'>
export type UpdateContractRequestContent = ExtractSchema<'UpdateContractRequestContent'>
export type UpdateContractResponseContent = ExtractSchema<'UpdateContractResponseContent'>
export type UpdateProfileRequestContent = ExtractSchema<'UpdateProfileRequestContent'>
export type UpdateProfileResponseContent = ExtractSchema<'UpdateProfileResponseContent'>
export type UploadProfilePictureRequestContent = ExtractSchema<'UploadProfilePictureRequestContent'>
export type UploadProfilePictureResponseContent = ExtractSchema<'UploadProfilePictureResponseContent'>
export type UserProfile = ExtractSchema<'UserProfile'>
export type ValidationErrorResponseContent = ExtractSchema<'ValidationErrorResponseContent'>
