$version: "2"

namespace equaliq

use equaliq#UuidLikeMixin
use equaliq#Email
use equaliq#Url
use equaliq#AuthenticationError
use equaliq#ResourceNotFoundError
use equaliq#ValidationError
use equaliq#InternalServerError

/// User resource and profile operations

// User identifier
string UserId with [UuidLikeMixin]

list UserIdList {
    member: UserId
}

// User resource
resource User {
    identifiers: { userId: UserId }
    read: GetProfile
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

// User operations
@readonly
@http(method: "POST", uri: "/getProfile")
operation GetProfile {
    input := {
        @required
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