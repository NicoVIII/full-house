import domain/basics/uuid
import domain/products/product
import gleam/dynamic/decode

pub fn total_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

pub fn product_id_value(product_id: product.Id) -> String {
  let product.ProductId(uid) = product_id
  uuid.value(uid)
}
