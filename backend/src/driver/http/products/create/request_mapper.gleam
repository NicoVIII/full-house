import common/product_id
import domain/basics/non_empty_set
import domain/products/product_name
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

fn map_name_error(error: product_name.ValidationError) -> String {
  case error {
    product_name.Empty -> "name must not be empty"
    product_name.LeadingOrTrailingWhitespace ->
      "name must not start or end with whitespace"
    product_name.InvalidCharacters -> "name must not contain tabs or newlines"
    product_name.TooLong -> "name must be 255 characters or less"
  }
}

fn join_name_errors(
  errors: non_empty_set.T(product_name.ValidationError),
) -> String {
  errors
  |> non_empty_set.to_list
  |> list.map(map_name_error)
  |> string.join("; ")
}

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

fn map_name(raw_name: String) -> Result(product_name.T, String) {
  case product_name.from_user_input(raw_name) {
    Ok(name) -> Ok(name)
    Error(errors) -> Error(join_name_errors(errors))
  }
}

fn map_parent_product_id(
  raw_parent_product_id: Option(String),
) -> Result(Option(product_id.T), String) {
  case raw_parent_product_id {
    None -> Ok(None)
    Some(raw_id) ->
      product_id.new(raw_id)
      |> result.map(Some)
      |> result.map_error(fn(_) { "parent_product_id must be a valid UUID" })
  }
}

pub fn map_payload(
  payload: Dynamic,
) -> Result(#(product_name.T, Option(product_id.T)), String) {
  use #(raw_name, raw_parent_product_id) <- result.try(
    decode.run(payload, payload_decoder())
    |> result.map_error(fn(_) {
      "request body must include string field `name` and optional string field `parent_product_id`"
    }),
  )
  use name <- result.try(map_name(raw_name))
  use parent_product_id <- result.try(map_parent_product_id(
    raw_parent_product_id,
  ))

  Ok(#(name, parent_product_id))
}
