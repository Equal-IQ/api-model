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
    user_pinned = "user_pinned"
    auto_pinned = "auto_pinned"
}

/// Reference type for quick access
enum ReferenceType {
    deal = "deal"
    file = "file"
    org = "org"
    user = "user"
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
    @required
    userId: UserId
    @required
    firstName: String
    @required
    lastName: String
    displayName: String
    @required
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

    @required
    pinType: PinType

    @required
    sortOrder: Integer

    @required
    createdAt: ISODate

    @required
    lastAccessedAt: ISODate

    /// Additional metadata for extensibility
    metadata: Document
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
        urlInfo: PresignedPostData
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
        ResourceNotFoundError
        InternalServerError
    ]
}

// Create Quick Access
@http(method: "POST", uri: "/quick-access/create")
operation CreateQuickAccess {
    input := {
        @required
        userId: UserId

        @required
        referenceType: ReferenceType

        @required
        referenceId: String

        @required
        pinType: PinType

        @required
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
@http(method: "POST", uri: "/quick-access/update")
operation UpdateQuickAccess {
    input := {
        @required
        quickAccessId: String

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
        items: QuickAccessMap

        /// Token for next page
        nextToken: String
    }

    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

// Helper map types
map QuickAccessMap {
    key: String  // quickAccessId
    value: QuickAccess
}