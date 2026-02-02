$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#Email
use equaliq#Url
use equaliq#ISODate
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// User resource and profile operations

/// Pin type for quick access items
enum PinType {
    USER_PINNED = "USER_PINNED"
    AUTO_PINNED = "AUTO_PINNED"
}

/// Reference type for quick access
enum ReferenceType {
    DEAL = "DEAL"
    FILE = "FILE"
    ORG = "ORG"
    USER = "USER"
}

// User identifier
string UserId with [UuidLikeMixin]

list UserIdList {
    member: UserId
}

// User resource
resource User {
    identifiers: { userId: UserId }
    update: UpdateProfile
    operations: [
        GetProfilePicture
        UploadProfilePicture
    ]
}

// User structures
structure UserProfile {
    userId: UserId
    firstName: String
    lastName: String
    displayName: String
    email: Email
    accountType: String
    bio: String
}

/// Quick access / pinned items for user navigation
structure QuickAccess {
    @required
    quickAccessId: String

    @required
    userId: UserId

    @required
    referenceType: ReferenceType

    @required
    referenceId: String

    /// Custom display name (optional, falls back to entity name)
    entryName: String

    /// Pin type (null = unpinned, just recently accessed)
    pinType: PinType

    @required
    sortOrder: Integer

    @required
    createdAt: ISODate

    /// Track for "recently viewed"
    lastAccessedAt: ISODate
}

// User operations
@readonly
@http(method: "POST", uri: "/getProfile")
operation GetProfile {
    input := {
        // Optional - if not provided, returns authenticated user's profile
        userId: UserId
    }

    output := {
        @required
        profile: UserProfile
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@readonly
@http(method: "POST", uri: "/getProfilePicture")
operation GetProfilePicture {
    input := {
        @required
        userId: UserId
    }

    output := {
        @required
        profilePictureURL: Url
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@http(method: "POST", uri: "/uploadProfilePicture")
operation UploadProfilePicture {
    input := {
        @required
        userId: UserId
    }

    output := {
        @required
        url_info: PresignedPostData
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

@idempotent
@http(method: "POST", uri: "/updateProfile")
operation UpdateProfile {
    input := {
        @required
        userId: UserId

        firstName: String
        lastName: String
        displayName: String
        accountType: String
        bio: String
        isOver18: Boolean
    }

    output := {
        @required
        profile: UserProfile
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Create Quick Access
@http(method: "POST", uri: "/quick-access")
operation CreateQuickAccess {
    input := {
        @required
        userId: UserId

        @required
        referenceType: ReferenceType

        @required
        referenceId: String

        entryName: String
        pinType: PinType
        sortOrder: Integer
    }

    output := {
        @required
        quickAccess: QuickAccess
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Update Quick Access
@idempotent
@http(method: "PUT", uri: "/quick-access/{quickAccessId}")
operation UpdateQuickAccess {
    input := {
        @required
        @httpLabel
        quickAccessId: String

        entryName: String
        pinType: PinType
        sortOrder: Integer
    }

    output := {
        @required
        quickAccess: QuickAccess
    }

    errors: [
        AuthenticationError
        ResourceNotFoundError
        ValidationError
        InternalServerError
    ]
}

// Delete Quick Access
@idempotent
@http(method: "POST", uri: "/quick-access/delete")
operation DeleteQuickAccess {
    input := {
        @required
        quickAccessId: String
    }

    output := {}

    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

// List Quick Access
@paginated(inputToken: "nextToken", outputToken: "nextToken", items: "items", pageSize: "limit")
@http(method: "POST", uri: "/quick-access/list")
operation ListQuickAccess {
    input := {
        @required
        userId: UserId

        /// Filter by pin type
        pinType: PinType

        /// Filter by reference type
        referenceType: ReferenceType

        /// Pagination cursor
        nextToken: String

        /// Page size
        limit: Integer
    }

    output := {
        @required
        items: QuickAccessList

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Helper list types
list QuickAccessList {
    member: QuickAccess
}