$version: "2"

namespace equaliq

// User profile operations and structures
string UserId with [UuidLikeMixin]

list UserIdList {
    member: UserId
}

enum AccountType {
    ARTIST = "artist"
    MANAGER = "manager"
    LAWYER = "lawyer"
    PRODUCER = "producer"
    PUBLISHER = "publisher"
    EXECUTIVE = "executive"
}

// User Profile operations
@http(method: "POST", uri: "/getProfile")
operation GetProfile {
    input: GetProfileInput
    output: GetProfileOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetProfileInput {
    // Optional - defaults to authenticated user if not provided
    userId: UserId
}

structure GetProfileOutput {
    @required
    userId: UserId

    @required
    profile: UserProfile
}

@http(method: "POST", uri: "/getProfilePicture")
operation GetProfilePicture {
    input: GetProfilePictureInput
    output: GetProfilePictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure GetProfilePictureInput {
    // Optional - defaults to authenticated user if not provided
  userId: UserId
}

structure GetProfilePictureOutput {
    @required
    profilePictureURL: Url
}

@http(method: "POST", uri: "/uploadProfilePicture")
operation UploadProfilePicture {
    input: UploadProfilePictureInput
    output: UploadProfilePictureOutput
    errors: [
        AuthenticationError
        ResourceNotFoundError
        InternalServerError
    ]
}

structure UploadProfilePictureInput {
}

structure UploadProfilePictureOutput {
    @required
    url_info: PresignedPostData
}

structure UserProfile {
    userId: UserId
    firstName: String
    lastName: String
    displayName: String
    email: Email
    accountType: AccountType
    bio: String
}

@idempotent
@http(method: "POST", uri: "/updateProfile")
operation UpdateProfile {
    input: UpdateProfileInput
    output: UpdateProfileOutput
    errors: [
        AuthenticationError
        ValidationError
        InternalServerError
    ]
}

structure UpdateProfileInput {
    firstName: String
    lastName: String
    displayName: String
    accountType: AccountType
    bio: String
    isOver18: Boolean
}

structure UpdateProfileOutput {
    @required
    success: Boolean

    @required
    message: String

    @required
    userId: UserId

    updatedFields: StringList
}
