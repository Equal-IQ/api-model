$version: "2"

namespace equaliq

enum SignatureStatus {
    SIGNED = "signed"
    DECLINED = "declined"
    PENDING = "pending"
}

enum SignContractResult {
    SUCCESS 
    FAILURE
}


@idempotent
@http(method: "POST", uri: "/sign")
operation SignContract {
    input: SignContractInput
    output: SignContractOutput
    errors: [
        AuthenticationError,
        ValidationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure SignContractInput {
    @required
    contractId: String
    @required
    status: SignatureStatus
}

structure SignContractOutput {
    @required
    result: SignContractResult
    message: String
}

@http(method: "POST", uri: "/getContractSignatures")
operation GetContractSignatures {
    input: GetContractSignaturesInput
    output: GetContractSignaturesOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure GetContractSignaturesInput {
    @required
    contractId: String
}

list SignatureList {
    member: ContractSignature
}

structure ContractSignature {
    userId: String
    status: SignatureStatus
    timestamp: Timestamp
}

structure GetContractSignaturesOutput {
    contractId: String
    signatures: SignatureList
}

@http(method: "POST", uri: "/updateSignatureStatus")
operation UpdateSignatureStatus {
    input: UpdateSignatureStatusInput
    output: UpdateSignatureStatusOutput
    errors: [
        AuthenticationError,
        ValidationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure UpdateSignatureStatusInput {
    @required
    contractId: ContractId
    @required
    status: SignatureStatus
}

structure UpdateSignatureStatusOutput {
    @required
    result: SignContractResult
    @required
    message: String
}

@idempotent
@http(method: "POST", uri: "/deleteContractSignature")
operation DeleteContractSignature {
    input: DeleteContractSignatureInput
    output: DeleteContractSignatureOutput
    errors: [
        AuthenticationError,
        ResourceNotFoundError,
        InternalServerError
    ]
}

structure DeleteContractSignatureInput {
    @required
    contractId: String
}

structure DeleteContractSignatureOutput {
    result: SignContractResult
    message: String
}
