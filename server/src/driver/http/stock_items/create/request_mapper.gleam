import common/product_id
import domain/stock_items/best_before_date
import driver/skirout/stock as skir_stock
import gleam/result
import skir_client/serializer

pub type Payload {
  Payload(product_id: product_id.T, best_before_date: best_before_date.T)
}

pub type Error {
  ParseError
  ProductIdError
  BestBeforeDateMissing
  BestBeforeDateFormatError
  BestBeforeDateInvalid
}

pub fn map_payload(body: String) -> Result(Payload, Error) {
  use req <- result.try(
    serializer.from_json_code(
      skir_stock.create_stock_item_request_serializer(),
      body,
    )
    // nolint: error_context_lost
    |> result.map_error(fn(_) { ParseError }),
  )

  use product_id <- result.try(
    product_id.new(req.product_id)
    |> result.map_error(fn(_) { ProductIdError }),
  )

  use best_before_date <- result.try(
    best_before_date.new(req.best_before_date)
    |> result.map_error(fn(error) {
      case error {
        best_before_date.Empty -> BestBeforeDateMissing
        best_before_date.InvalidFormat -> BestBeforeDateFormatError
        best_before_date.InvalidDate -> BestBeforeDateInvalid
      }
    }),
  )

  Ok(Payload(product_id:, best_before_date:))
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ParseError -> "payload is invalid"
    ProductIdError -> "product_id is not a valid UUID"
    BestBeforeDateMissing -> "best_before_date is required"
    BestBeforeDateFormatError -> "best_before_date must use format YYYY-MM-DD"
    BestBeforeDateInvalid -> "best_before_date is not a valid calendar date"
  }
}
