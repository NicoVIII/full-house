import gleam/json
import wisp

pub fn handle_result(
  value: Result(a, e),
  error_response: wisp.Response,
  next: fn(a) -> wisp.Response,
) -> wisp.Response {
  case value {
    Ok(ok) -> next(ok)
    Error(_) -> error_response
  }
}

pub fn bad_request(message: String) -> wisp.Response {
  json.object([
    #("error", json.string("invalid_parameter")),
    #("message", json.string(message)),
  ])
  |> json.to_string
  |> fn(body) { wisp.json_response(body, 400) }
}
