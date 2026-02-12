$version: "2"

namespace equaliq

use aws.protocols#restJson1
use equaliq#UuidLikeMixin
use equaliq#ISODate
use equaliq#Url
use equaliq#StringList
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// File identifier
string FileId with [UuidLikeMixin]

/// File resource with sub-resources for access control
resource FileResource {
    identifiers: { fileId: FileId }
    create: CreateFile
    read: GetFile
    update: UpdateFile
    delete: DeleteFile
    list: ListFiles
    resources: [FileAccessResource]
    operations: [
        GenerateUploadUrl
        GenerateDownloadUrl
    ]
}

/// File entity
structure File {
    @required
    fileId: FileId

    @required
    ownerOrgId: String

    @required
    createdByUserId: String

    @required
    fileName: String

    @required
    s3Key: String

    @required
    s3Bucket: String

    @required
    sizeBytes: Long

    @required
    fileType: String

    /// Virtual folder path
    folderPath: String

    /// File description
    description: String

    /// User-defined tags
    tags: StringList

    /// Associated deal if applicable
    dealId: String

    /// Associated deal version if applicable
    dealVersionId: String

    /// Additional metadata as JSON
    metadata: Document

    @required
    createdAt: ISODate

    @required
    updatedAt: ISODate
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
@http(method: "POST", uri: "/files/create")
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
@readonly
@http(method: "POST", uri: "/files/get")
operation GetFile {
    input := {
        @required
        fileId: FileId

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
@http(method: "POST", uri: "/files/update")
operation UpdateFile {
    input := {
        @required
        fileId: FileId

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
        fileId: FileId

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
@readonly
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
@http(method: "POST", uri: "/files/upload-url")
operation GenerateUploadUrl {
    input := {
        @required
        fileId: FileId

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
@http(method: "POST", uri: "/files/download-url")
operation GenerateDownloadUrl {
    input := {
        @required
        fileId: FileId

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

// Helper list types
list FileList {
    member: File
}

list FileAccessList {
    member: FileAccess
}