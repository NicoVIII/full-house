import wisp

type NextFn(a) =
  fn(a) -> wisp.Response

type OnErrorFn(a) =
  fn(NextFn(a)) -> wisp.Response

/// Useful to handle errors with use expression in handlers
pub fn on_error(
  value: Result(a, e),
  on_error: fn(e) -> wisp.Response,
) -> OnErrorFn(a) {
  fn(next: NextFn(a)) -> wisp.Response {
    case value {
      Ok(ok) -> next(ok)
      Error(err) -> on_error(err)
    }
  }
}

/// Useful to handle errors with use expression in handlers
/// Returns a fixed value no matter the error
pub fn on_error_value(
  value value: Result(a, e),
  on_error on_error_response: wisp.Response,
) -> OnErrorFn(a) {
  on_error(value, fn(_) { on_error_response })
}

pub fn conflict(message: String) -> wisp.Response {
  wisp.response(409)
  |> wisp.set_header("content-type", "text/plain")
  |> wisp.set_body(wisp.Text(message))
}
