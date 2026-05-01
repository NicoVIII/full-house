import application/commands/ports/delete as delete_product_port
import domain/products/product
import gleam/dynamic/decode
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn map_delete_error(error: sqlight.Error) -> delete_product_port.Error {
  case error {
    sqlight.SqlightError(code: sqlight.ConstraintForeignkey, ..) ->
      delete_product_port.ProductStillReferenced
    _ -> delete_product_port.DatabaseFailure
  }
}

fn deletion_attempt_decoder() -> decode.Decoder(Int) {
  decode.field(0, decode.int, decode.success)
}

fn delete_product(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(Nil, delete_product_port.Error) {
  let id_str = shared.product_id_value(product_id)

  use rows <- result.try(
    sqlight.query(
      "
      delete from products
      where id = ?
      returning 1
      ",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: deletion_attempt_decoder(),
    )
    |> result.map_error(map_delete_error),
  )

  case rows {
    [] -> Error(delete_product_port.ProductNotFound)
    _ -> Ok(Nil)
  }
}

pub fn new(connection: sqlight.Connection) -> delete_product_port.T {
  delete_product_port.T(delete: fn(product_id) {
    delete_product(connection, product_id)
  })
}
