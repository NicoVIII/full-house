import application/commands/delete_product
import application/shared/infrastructure_error
import domain/products/deletable_product_id
import gleam/dynamic/decode
import sqlight

fn deletion_attempt_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn delete_product(
  id: deletable_product_id.T,
  connection: sqlight.Connection,
) -> Result(Nil, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      DELETE FROM products
      WHERE id = ?
      RETURNING 1
      ",
      on: connection,
      with: [sqlight.text(deletable_product_id.value(id))],
      expecting: deletion_attempt_decoder(),
    )

  case query_result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

pub fn new(connection: sqlight.Connection) -> delete_product.DeletePort {
  fn(id) { delete_product(id, connection) }
}
