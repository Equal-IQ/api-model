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

/// Conflict with current server state. Use when the request is well-formed
/// and the caller is authorized, but the action conflicts with existing
/// resources (duplicate member, bot already scheduled, role-name collision).
/// Distinct from ProcessingIncompleteError, which carries the same 409 status
/// but signals "resource exists, not ready yet."
@error("client")
@httpError(409)
structure ConflictError {
  @required
  message: String
}

@error("server")
structure InternalServerError {
  @required
  message: String
}