import common/product_id
import domain/basics/non_empty_set
import domain/products/product_name
import driver/skirout/product as skir_product
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import skir_client/serializer

pub type Error {
  ParseError
  ProductNameError(non_empty_set.T(product_name.ValidationError))
  ParentProductIdError
}

pub fn map_payload(
  body: String,
) -> Result(#(product_name.T, Option(product_id.T)), Error) {
  use req <- result.try(
    serializer.from_json_code(
      skir_product.create_product_request_serializer(),
      body,
    )
    // nolint: error_context_lost
    |> result.map_error(fn(_) { ParseError }),
  )

  use name <- result.try(
    product_name.from_user_input(req.name) |> result.map_error(ProductNameError),
  )

  use parent_product_id <- result.try(case req.parent_product_id {
    None -> Ok(None)
    Some(raw_id) ->
      product_id.new(raw_id)
      |> result.map(Some)
      // nolint: error_context_lost
      |> result.map_error(fn(_) { ParentProductIdError })
  })

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
