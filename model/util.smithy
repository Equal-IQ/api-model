$version: "2"

namespace equaliq

// Shared types used across operations - keep these in main file for reference

structure EmptyStructure {
    // Empty structure - avoid using, but useful in data migrations or making union workable
}

// Common patterns
@mixin
@pattern("^[A-Za-z0-9-]+$")
string UuidLikeMixin

@pattern("^[\\w-\\.]+@[\\w-\\.]+\\.+[\\w-]{1,63}$")
string Email

string Url // Putting a regex on this is a nightmare, so leaving it open for now

// Generics
list StringList {
    member: String
}

list EmailList {
    member: Email
}