import common/product_id
import domain/basics/non_empty_set
import domain/products/product_name
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

fn payload_decoder() -> decode.Decoder(#(String, Option(String))) {
  {
    use name <- decode.field("name", decode.string)
    use parent_product_id <- decode.optional_field(
      "parent_product_id",
      None,
      decode.optional(decode.string),
    )
    decode.success(#(name, parent_product_id))
  }
}

fn parse_parent_product_id(
  raw_parent_product_id: Option(String),
) -> Result(Option(product_id.T), Nil) {
  case raw_parent_product_id {
    None -> Ok(None)
    Some(raw_id) ->
      product_id.new(raw_id)
      |> result.map(Some)
  }
}

pub type Error {
  ParseError
  ProductNameError(non_empty_set.T(product_name.ValidationError))
  ParentProductIdError
}

pub fn map_payload(
  payload: Dynamic,
) -> Result(#(product_name.T, Option(product_id.T)), Error) {
  use #(raw_name, raw_parent_product_id) <- result.try(
    case decode.run(payload, payload_decoder()) {
      Ok(decoded) -> Ok(decoded)
      Error(_) -> Error(ParseError)
    },
  )
  use name <- result.try(
    product_name.from_user_input(raw_name) |> result.map_error(ProductNameError),
  )
  use parent_product_id <- result.try(
    case parse_parent_product_id(raw_parent_product_id) {
      Ok(parent_product_id) -> Ok(parent_product_id)
      Error(_) -> Error(ParentProductIdError)
    },
  )

  Ok(#(name, parent_product_id))
}

fn single_error_to_string(error: product_name.ValidationError) -> String {
  case error {
    product_name.Empty -> "name must not be empty"
    product_name.LeadingOrTrailingWhitespace ->
      "name must not start or end with whitespace"
    product_name.InvalidCharacters -> "name must not contain tabs or newlines"
    product_name.TooLong -> "name must be 255 characters or less"
  }
}

pub fn error_to_string(error: Error) -> String {
  case error {
    ProductNameError(errors) ->
      non_empty_set.to_list(errors)
      |> list.map(single_error_to_string)
      |> string.join("\n")
    ParentProductIdError -> "parent_product_id is invalid"
    ParseError -> "payload is invalid"
  }
}
