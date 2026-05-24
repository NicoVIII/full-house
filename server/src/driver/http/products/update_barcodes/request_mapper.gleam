import driver/skirout/product as skir_product
import gleam/result
import skir_client/serializer

pub type Error {
  ParseError
}

pub fn map_payload(
  body: String,
) -> Result(#(List(String), List(String)), Error) {
  use req <- result.try(
    serializer.from_json_code(
      skir_product.update_product_barcodes_patch_serializer(),
      body,
    )
    // nolint: error_context_lost
    |> result.map_error(fn(_) { ParseError }),
  )

  Ok(#(req.add_barcodes, req.remove_barcodes))
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ParseError -> "payload is invalid"
  }
}
