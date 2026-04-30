import application/ports/products/list_child_ids as list_child_ids_port
import domain/products/product
import gleam/dynamic/decode
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn map_child_ids_error(_: sqlight.Error) -> list_child_ids_port.Error {
  list_child_ids_port.DatabaseFailure
}

fn child_id_row_decoder() -> decode.Decoder(String) {
  use id <- decode.field(0, decode.string)
  decode.success(id)
}

fn load_child_ids(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(List(String), list_child_ids_port.Error) {
  use child_id_rows <- result.try(
    sqlight.query(
      "
      select id
      from products
      where parent_product_id = ?
      order by name
      ",
      on: connection,
      with: [sqlight.text(shared.product_id_value(product_id))],
      expecting: child_id_row_decoder(),
    )
    |> result.map_error(map_child_ids_error),
  )

  Ok(child_id_rows)
}

pub fn new(connection: sqlight.Connection) -> list_child_ids_port.T {
  list_child_ids_port.T(load: fn(product_id) {
    load_child_ids(connection, product_id)
  })
}
