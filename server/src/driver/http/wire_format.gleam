import gleam/http/request
import gleam/result
import wisp

pub type T {
  ReadableJson
  DenseJson
  Binary
}

pub const readable_json_mime = "application/json"

pub const dense_json_mime = "application/vnd.skir.dense+json"

pub const binary_mime = "application/vnd.skir.binary"

fn from_mime_type(mime: String) -> T {
  case mime {
    "application/json" -> ReadableJson
    "application/vnd.skir.dense+json" -> DenseJson
    "application/vnd.skir.binary" -> Binary
    _ -> DenseJson
  }
}

pub fn from_accept_header(request: wisp.Request) -> T {
  request.get_header(request, "accept")
  |> result.map(from_mime_type)
  |> result.unwrap(DenseJson)
}
