import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/dynamic/decode
import gleam/option
import gleam/set
import sqlight

pub fn product() -> decode.Decoder(product.T) {
  use id <- decode.field(0, decode.string)
  use name <- decode.field(1, decode.string)
  use parent_id <- decode.field(2, decode.optional(decode.string))

  // nolint: assert_ok_pattern -- We assume that data in the database is valid
  let assert Ok(id) = product_id.new(id)
  // nolint: assert_ok_pattern -- We assume that data in the database is valid
  let assert Ok(name) = product_name.new(name)
  let parent_id =
    option.map(parent_id, fn(parent_id) {
      // nolint: assert_ok_pattern -- We assume that data in the database is valid
      let assert Ok(parent_id) = product_id.new(parent_id)
      // nolint: assert_ok_pattern -- We are sure that the parent product exists because of the foreign key constraint in the database
      let assert Ok(parent_id) = existing_product_id.prove(parent_id, True)
      parent_id
    })

  decode.success(product.hydrate(id, name, parent_id, set.new()))
}

pub fn count() -> decode.Decoder(Int) {
  use total <- decode.field(0, decode.int)
  decode.success(total)
}

pub fn exists() -> decode.Decoder(Bool) {
  use exists <- decode.field(0, sqlight.decode_bool())
  decode.success(exists)
}
