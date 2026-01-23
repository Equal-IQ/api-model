$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#ISODate
use equaliq#Url
use equaliq#StringList
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// File entity
structure File {
    @required
    fileId: String

    @required
    orgId: String

    @required
    uploadedBy: String

    @required
    fileName: String

    @required
    s3Key: String

    @required
    s3Bucket: String

    @required
    sizeBytes: Long

    /// MIME type
    fileType: String

    /// Virtual folder path
    folderPath: String

    /// User-defined tags
    tags: StringList

    /// Associated deal if applicable
    dealId: String

    /// Associated deal version if applicable
    dealVersionId: String

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate

    /// Soft delete tracking
    deletedAt: ISODate
    deletedBy: String
}

/// Presigned URL response
structure PresignedUrl {
    @required
    url: Url

    @required
    expiresAt: ISODate

    /// HTTP method for the URL
    method: String

    /// Required headers for the request
    headers: Document
}

// Create File
@http(method: "POST", uri: "/files")
operation CreateFile {
    input := {
        @required
        orgId: String

        @required
        fileName: String

        @required
        sizeBytes: Long

        /// MIME type
        fileType: String

        /// Virtual folder path
        folderPath: String

        /// User-defined tags
        tags: StringList

        /// Associated deal if applicable
        dealId: String

        /// Associated deal version if applicable
        dealVersionId: String

        /// Request upload URL in response
        requestUploadUrl: Boolean
    }

    output := {
        @required
        file: File

        /// Presigned URL for upload if requested
        uploadUrl: PresignedUrl
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Get File
@http(method: "POST", uri: "/files/get")
operation GetFile {
    input := {
        @required
        fileId: String

        /// Include access information
        includeAccess: Boolean

        /// Request download URL in response
        requestDownloadUrl: Boolean
    }

    output := {
        @required
        file: File

        /// Access information if requested
        access: FileAccessList

        /// Presigned URL for download if requested
        downloadUrl: PresignedUrl
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// Update File
@idempotent
@http(method: "PUT", uri: "/files/{fileId}")
operation UpdateFile {
    input := {
        @required
        @httpLabel
        fileId: String

        fileName: String
        folderPath: String
        tags: StringList
        dealId: String
        dealVersionId: String
    }

    output := {
        @required
        file: File
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Delete File
@idempotent
@http(method: "POST", uri: "/files/delete")
operation DeleteFile {
    input := {
        @required
        fileId: String

        /// Hard delete the file (default is soft delete)
        hardDelete: Boolean
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Files
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "files", pageSize: "limit")
@http(method: "POST", uri: "/files/list")
operation ListFiles {
    input := {
        /// Filter by organization
        orgId: String

        /// Filter by deal
        dealId: String

        /// Filter by deal version
        dealVersionId: String

        /// Filter by folder path
        folderPath: String

        /// Filter by tags (any match)
        tags: StringList

        /// Filter by uploader
        uploadedBy: String

        /// Include deleted files
        includeDeleted: Boolean

        /// Pagination cursor (encoded fileId)
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        files: FileList

        /// Token for next page
        nextToken: String

        /// Total size of files in current page
        totalSizeBytes: Long
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Generate Upload URL
@http(method: "POST", uri: "/files/{fileId}/upload-url")
operation GenerateUploadUrl {
    input := {
        @required
        @httpLabel
        fileId: String

        /// Content type for the upload
        contentType: String

        /// Expiration time in seconds (default 3600)
        expirationSeconds: Integer
    }

    output := {
        @required
        uploadUrl: PresignedUrl
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Generate Download URL
@http(method: "POST", uri: "/files/{fileId}/download-url")
operation GenerateDownloadUrl {
    input := {
        @required
        @httpLabel
        fileId: String

        /// Expiration time in seconds (default 3600)
        expirationSeconds: Integer

        /// Content disposition (inline or attachment)
        disposition: String

        /// Override filename in download
        downloadFileName: String
    }

    output := {
        @required
        downloadUrl: PresignedUrl
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Batch File Operations
@http(method: "POST", uri: "/files/batch")
operation BatchFileOperation {
    input := {
        @required
        operation: BatchOperation

        @required
        fileIds: StringList

        /// For move operation
        targetFolderPath: String

        /// For tag operations
        tags: StringList

        /// For delete operation
        hardDelete: Boolean
    }

    output := {
        @required
        successCount: Integer

        @required
        failureCount: Integer

        /// Details of failed operations
        failures: BatchFailureList
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

/// Batch operation types
enum BatchOperation {
    MOVE = "MOVE"
    ADD_TAGS = "ADD_TAGS"
    REMOVE_TAGS = "REMOVE_TAGS"
    DELETE = "DELETE"
}

/// Batch operation failure
structure BatchFailure {
    @required
    fileId: String

    @required
    reason: String
}

// Helper list types
list FileList {
    member: File
}

list FileAccessList {
    member: FileAccess
}

list BatchFailureList {
    member: BatchFailure
}