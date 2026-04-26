import application/ports/products/delete as delete_product_port
import domain/product
import gleam/dynamic/decode
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn delete_product(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(Nil, delete_product_port.Error) {
  let id_str = shared.product_id_value(product_id)

  use _ <- result.try(
    sqlight.query(
      "delete from products where id = ?",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: decode.success(#()),
    )
    |> result.map_error(fn(_) { delete_product_port.DatabaseFailure }),
  )

  Ok(Nil)
}

pub fn new(connection: sqlight.Connection) -> delete_product_port.T {
  delete_product_port.T(delete: fn(product_id) {
    delete_product(connection, product_id)
  })
}
