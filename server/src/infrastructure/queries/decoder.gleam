import application/queries/common/product_query_model
import gleam/dynamic/decode
import gleam/option.{None, Some}
import gleam/string
import sqlight

pub fn product_query_model() -> decode.Decoder(product_query_model.T) {
  use id <- decode.field(0, decode.string)
  use name <- decode.field(1, decode.string)
  use parent_id <- decode.field(2, decode.optional(decode.string))
  use children_ids_joined <- decode.field(3, decode.optional(decode.string))
  use barcodes_joined <- decode.field(4, decode.optional(decode.string))
  let children_ids = case children_ids_joined {
    Some(joined) -> string.split(joined, ",")
    None -> []
  }
  let barcodes = case barcodes_joined {
    Some(joined) -> string.split(joined, ",")
    None -> []
  }
  decode.success(product_query_model.ProductQueryModel(
    id,
    name,
    parent_id,
    children_ids,
    barcodes,
  ))
}

pub fn count() -> decode.Decoder(Int) {
  use total <- decode.field(0, decode.int)
  decode.success(total)
}

pub fn exists() -> decode.Decoder(Bool) {
  use exists <- decode.field(0, sqlight.decode_bool())
  decode.success(exists)
}
