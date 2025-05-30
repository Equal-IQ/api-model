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

export type AccountType = ExtractSchema<'AccountType'>
export type ArchiveComposerContractRequestContent = ExtractSchema<'ArchiveComposerContractRequestContent'>
export type ArchiveComposerContractResponseContent = ExtractSchema<'ArchiveComposerContractResponseContent'>
export type AuthenticationErrorResponseContent = ExtractSchema<'AuthenticationErrorResponseContent'>
export type ClauseSection = ExtractSchema<'ClauseSection'>
export type ComposerContractContent = ExtractSchema<'ComposerContractContent'>
export type ComposerContractData = ExtractSchema<'ComposerContractData'>
export type ComposerContractMeta = ExtractSchema<'ComposerContractMeta'>
export type ComposerContractSection = ExtractSchema<'ComposerContractSection'>
export type ComposerContractStatus = ExtractSchema<'ComposerContractStatus'>
export type ComposerContractType = ExtractSchema<'ComposerContractType'>
export type ComposerFormData = ExtractSchema<'ComposerFormData'>
export type ContractSignature = ExtractSchema<'ContractSignature'>
export type ContractStatus = ExtractSchema<'ContractStatus'>
export type ContractSummaryItem = ExtractSchema<'ContractSummaryItem'>
export type ContractType = ExtractSchema<'ContractType'>
export type CreateComposerContractRequestContent = ExtractSchema<'CreateComposerContractRequestContent'>
export type CreateComposerContractResponseContent = ExtractSchema<'CreateComposerContractResponseContent'>
export type DeleteContractRequestContent = ExtractSchema<'DeleteContractRequestContent'>
export type DeleteContractResponseContent = ExtractSchema<'DeleteContractResponseContent'>
export type DeleteContractSignatureRequestContent = ExtractSchema<'DeleteContractSignatureRequestContent'>
export type DeleteContractSignatureResponseContent = ExtractSchema<'DeleteContractSignatureResponseContent'>
export type ExposeTypesResponseContent = ExtractSchema<'ExposeTypesResponseContent'>
export type FixedTermValue = ExtractSchema<'FixedTermValue'>
export type FixedValueTermInference = ExtractSchema<'FixedValueTermInference'>
export type GetContractReadURLRequestContent = ExtractSchema<'GetContractReadURLRequestContent'>
export type GetContractReadURLResponseContent = ExtractSchema<'GetContractReadURLResponseContent'>
export type GetContractRequestContent = ExtractSchema<'GetContractRequestContent'>
export type GetContractResponseContent = ExtractSchema<'GetContractResponseContent'>
export type GetContractSignaturesRequestContent = ExtractSchema<'GetContractSignaturesRequestContent'>
export type GetContractSignaturesResponseContent = ExtractSchema<'GetContractSignaturesResponseContent'>
export type GetProfilePictureRequestContent = ExtractSchema<'GetProfilePictureRequestContent'>
export type GetProfilePictureResponseContent = ExtractSchema<'GetProfilePictureResponseContent'>
export type GetProfileRequestContent = ExtractSchema<'GetProfileRequestContent'>
export type GetProfileResponseContent = ExtractSchema<'GetProfileResponseContent'>
export type GetUploadURLRequestContent = ExtractSchema<'GetUploadURLRequestContent'>
export type GetUploadURLResponseContent = ExtractSchema<'GetUploadURLResponseContent'>
export type InternalServerErrorResponseContent = ExtractSchema<'InternalServerErrorResponseContent'>
export type ListComposerContractVersionsRequestContent = ExtractSchema<'ListComposerContractVersionsRequestContent'>
export type ListComposerContractVersionsResponseContent = ExtractSchema<'ListComposerContractVersionsResponseContent'>
export type ListComposerContractsResponseContent = ExtractSchema<'ListComposerContractsResponseContent'>
export type ListContractsResponseContent = ExtractSchema<'ListContractsResponseContent'>
export type PingResponseContent = ExtractSchema<'PingResponseContent'>
export type PresignedPostData = ExtractSchema<'PresignedPostData'>
export type ProcessingIncompleteErrorResponseContent = ExtractSchema<'ProcessingIncompleteErrorResponseContent'>
export type QA = ExtractSchema<'QA'>
export type QASection = ExtractSchema<'QASection'>
export type ResourceNotFoundErrorResponseContent = ExtractSchema<'ResourceNotFoundErrorResponseContent'>
export type SaveComposerContractToVaultRequestContent = ExtractSchema<'SaveComposerContractToVaultRequestContent'>
export type SaveComposerContractToVaultResponseContent = ExtractSchema<'SaveComposerContractToVaultResponseContent'>
export type SectionUnion = ExtractSchema<'SectionUnion'>
export type ShareContractRequestContent = ExtractSchema<'ShareContractRequestContent'>
export type ShareContractResponseContent = ExtractSchema<'ShareContractResponseContent'>
export type SharedUserDetails = ExtractSchema<'SharedUserDetails'>
export type SignContractRequestContent = ExtractSchema<'SignContractRequestContent'>
export type SignContractResponseContent = ExtractSchema<'SignContractResponseContent'>
export type SignContractResult = ExtractSchema<'SignContractResult'>
export type SignatureStatus = ExtractSchema<'SignatureStatus'>
export type Term = ExtractSchema<'Term'>
export type UpdateContractRequestContent = ExtractSchema<'UpdateContractRequestContent'>
export type UpdateContractResponseContent = ExtractSchema<'UpdateContractResponseContent'>
export type UpdateProfileRequestContent = ExtractSchema<'UpdateProfileRequestContent'>
export type UpdateProfileResponseContent = ExtractSchema<'UpdateProfileResponseContent'>
export type UpdateSignatureStatusRequestContent = ExtractSchema<'UpdateSignatureStatusRequestContent'>
export type UpdateSignatureStatusResponseContent = ExtractSchema<'UpdateSignatureStatusResponseContent'>
export type UploadProfilePictureRequestContent = ExtractSchema<'UploadProfilePictureRequestContent'>
export type UploadProfilePictureResponseContent = ExtractSchema<'UploadProfilePictureResponseContent'>
export type UserProfile = ExtractSchema<'UserProfile'>
export type ValidationErrorResponseContent = ExtractSchema<'ValidationErrorResponseContent'>
