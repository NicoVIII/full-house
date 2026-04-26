import application/ports/products/stock_references as stock_references_port
import domain/product
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn count_stock_by_product_id(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(Int, stock_references_port.Error) {
  let id_str = shared.product_id_value(product_id)

  use rows <- result.try(
    sqlight.query(
      "select count(*) from stock_items where product_id = ?",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(fn(_) { stock_references_port.DatabaseFailure }),
  )

  let assert [count] = rows
  Ok(count)
}

pub fn new(connection: sqlight.Connection) -> stock_references_port.T {
  stock_references_port.T(count_by_product_id: fn(product_id) {
    count_stock_by_product_id(connection, product_id)
  })
}
