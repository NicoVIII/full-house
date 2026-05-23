import driver/skirout/product as skir_product
import gleam/option.{type Option}
import gleam/result
import skir_client/serializer

pub type Error {
  ParseError
}

pub fn map_payload(body: String) -> Result(#(String, Option(String)), Error) {
  use req <- result.try(
    serializer.from_json_code(
      skir_product.create_product_request_serializer(),
      body,
    )
    // nolint: error_context_lost
    |> result.map_error(fn(_) { ParseError }),
  )

  Ok(#(req.name, req.parent_product_id))
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ParseError -> "payload is invalid"
  }
}
