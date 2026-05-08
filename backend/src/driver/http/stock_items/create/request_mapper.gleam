import common/product_id
import driver/skirout/stock as skir_stock
import gleam/result
import skir_client/serializer

pub type Error {
  ParseError
  ProductIdError
}

pub fn map_payload(body: String) -> Result(product_id.T, Error) {
  use req <- result.try(
    serializer.from_json_code(
      skir_stock.create_stock_item_request_serializer(),
      body,
    )
    // nolint: error_context_lost
    |> result.map_error(fn(_) { ParseError }),
  )

  product_id.new(req.product_id)
  // nolint: error_context_lost
  |> result.map_error(fn(_) { ProductIdError })
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ParseError -> "payload is invalid"
    ProductIdError -> "product_id is not a valid UUID"
  }
}
