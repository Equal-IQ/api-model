$version: "2"

namespace equaliq

// Shared types used across operations - keep these in main file for reference

// Common patterns
@mixin
@pattern("^[A-Za-z0-9-]+$")
string UuidLikeMixin

@pattern("^[\\w-\\.]+@[\\w-\\.]+\\.+[\\w-]{1,63}$")
string Email

// Generics
list StringList {
    member: String
}

list EmailList {
    member: Email
}