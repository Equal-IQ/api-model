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

@pattern("^\\d{4}-[01]\\d-[0-3]dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+([+-][0-2]\\d:[0-5]\\d|Z)$")
string ISODate

string Url // Putting a regex on this is a nightmare, so leaving it open for now

// Generics
list StringList {
    member: String
}

list EmailList {
    member: Email
}