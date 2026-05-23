import driver/skir/setup
import gleam/bit_array
import gleam/erlang/process
import gleam/http
import gleam/option
import gleam/result
import gleam/uri
import skir_client/service
import wisp

fn from_raw_response(raw: service.RawResponse) -> wisp.Response {
  wisp.response(raw.status_code)
  |> wisp.set_header("content-type", raw.content_type)
  |> wisp.set_body(wisp.Text(raw.data))
}

fn handle_get(
  req: wisp.Request,
  server_name: setup.ServerName,
) -> wisp.Response {
  let raw_query = option.unwrap(req.query, "")
  let decoded_query = result.unwrap(uri.percent_decode(raw_query), raw_query)
  let raw =
    process.call_forever(process.named_subject(server_name), setup.HandleRpc(
      decoded_query,
      _,
    ))
  from_raw_response(raw)
}

fn handle_post(
  req: wisp.Request,
  server_name: setup.ServerName,
) -> wisp.Response {
  case wisp.read_body_bits(req) {
    Error(_) -> wisp.bad_request("failed to read request body")
    Ok(body) ->
      case bit_array.to_string(body) {
        Error(_) -> wisp.bad_request("body is not valid UTF-8")
        Ok(body_str) ->
          process.call_forever(
            process.named_subject(server_name),
            setup.HandleRpc(body_str, _),
          )
          |> from_raw_response
      }
  }
}

pub fn handle_rpc_message(
  request: wisp.Request,
  server_name: setup.ServerName,
) -> wisp.Response {
  case request.method {
    http.Get -> handle_get(request, server_name)
    http.Post -> handle_post(request, server_name)
    _ -> wisp.method_not_allowed(allowed: [http.Get, http.Post])
  }
}
