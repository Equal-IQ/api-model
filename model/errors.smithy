$version: "2"

namespace equaliq

/// Common error structures used across all operations

@error("client")
structure AuthenticationError {
  @required
  message: String
}

@error("client")
structure ResourceNotFoundError {
  @required
  message: String
}

@error("client")
structure ValidationError {
  @required
  message: String
}

@error("client")
structure ProcessingIncompleteError {
  @required
  message: String
}

@error("server")
structure InternalServerError {
  @required
  message: String
}