import application/ports/products/child_references as child_references_port
import domain/product
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn count_child_by_parent_id(
  connection: sqlight.Connection,
  parent_id: product.Id,
) -> Result(Int, child_references_port.Error) {
  let id_str = shared.product_id_value(parent_id)

  use rows <- result.try(
    sqlight.query(
      "select count(*) from products where parent_product_id = ?",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(fn(_) { child_references_port.DatabaseFailure }),
  )

  let assert [count] = rows
  Ok(count)
}

pub fn new(connection: sqlight.Connection) -> child_references_port.T {
  child_references_port.T(count_by_parent_id: fn(product_id) {
    count_child_by_parent_id(connection, product_id)
  })
}
