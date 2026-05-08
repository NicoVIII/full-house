import common/product_id
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/result

fn payload_decoder() -> decode.Decoder(String) {
  use product_id <- decode.field("product_id", decode.string)
  decode.success(product_id)
}

pub type Error {
  ParseError
  ProductIdError
}

pub fn map_payload(payload: Dynamic) -> Result(product_id.T, Error) {
  use raw_product_id <- result.try(case decode.run(payload, payload_decoder()) {
    Ok(decoded) -> Ok(decoded)
    Error(_) -> Error(ParseError)
  })

  case product_id.new(raw_product_id) {
    Ok(id) -> Ok(id)
    Error(Nil) -> Error(ProductIdError)
  }
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ParseError -> "payload is invalid"
    ProductIdError -> "product_id is not a valid UUID"
  }
}
