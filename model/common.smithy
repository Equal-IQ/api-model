$version: "2"

metadata suppressions = [
  {
    id: "EnumShape",
    namespace: "equaliq"
  }
]

namespace equaliq

/// Common types and structures shared across all operations

structure EmptyStructure {
  // Empty structure - avoid using, but useful in data migrations or making union workable
}

// Common string patterns
@mixin
@pattern("^[A-Za-z0-9-]+$")
string UuidLikeMixin

@pattern("^[\\w-\\.]+@[\\w-\\.]+\\.+[\\w-]{1,63}$")
string Email

@pattern("^\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+([+-][0-2]\\d:[0-5]\\d|Z)$")
string ISODate

@pattern("^(https?:\\/\\/)?(www\\.)?[-a-zA-Z0-9@%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&\/=]*)$")
string Url // This pattern passes for any URLs we're currently using (S3 Presigned URLs)

@pattern("^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$")
string HexColor

// Generic list types
list StringList {
  member: String
}

list EmailList {
  member: Email
}

// Text structures
// We plan to extend this Tagged Text system to a more structured format
structure TaggedText {
  @required
  text: String
}

structure PlainText {
  @required
  text: String
}