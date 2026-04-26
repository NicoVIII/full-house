import domain/basics/uuid
import domain/product
import domain/product_name
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import gleam/result

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
  case product_name.new(raw_name) {
    Ok(name) -> Ok(name)
    Error(product_name.Empty) -> Error("name must not be empty")
    Error(product_name.TooLong) -> Error("name must be 255 characters or less")
  }
}

fn map_parent_product_id(
  raw_parent_product_id: Option(String),
) -> Result(Option(product.Id), String) {
  case raw_parent_product_id {
    None -> Ok(None)
    Some(raw_id) ->
      uuid.new(raw_id)
      |> result.map(product.ProductId)
      |> result.map(Some)
      |> result.map_error(fn(_) { "parent_product_id must be a valid UUID" })
  }
}

pub fn map_payload(
  payload: Dynamic,
) -> Result(#(product_name.T, Option(product.Id)), String) {
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
