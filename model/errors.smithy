$version: "2"

namespace equaliq

/// Common error structures used across all operations

@error("client")
@httpError(401)
structure AuthenticationError {
  @required
  message: String
}

@error("client")
@httpError(404)
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
@httpError(409)
structure ProcessingIncompleteError {
  @required
  message: String
}

@error("server")
structure InternalServerError {
  @required
  message: String
}