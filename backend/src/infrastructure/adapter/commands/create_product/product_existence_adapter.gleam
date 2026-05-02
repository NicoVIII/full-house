import application/commands/create_product
import application/shared/infrastructure_error
import common/product_id
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import sqlight

fn id_decoder() -> decode.Decoder(#(Option(String))) {
  {
    use id <- decode.field(0, decode.optional(decode.string))
    decode.success(#(id))
  }
}

fn check_existence(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT id FROM products WHERE id = ?
      ",
      on: connection,
      with: [sqlight.text(product_id.value(id))],
      expecting: id_decoder(),
    )

  case query_result {
    Ok([#(Some(_))]) -> Ok(True)
    Ok([#(None)]) -> Ok(False)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    Ok(_) -> panic as "Unexpected query result format"
  }
}

pub fn new(
  connection: sqlight.Connection,
) -> create_product.ProductExistencePort {
  fn(id) { check_existence(id, connection) }
}
