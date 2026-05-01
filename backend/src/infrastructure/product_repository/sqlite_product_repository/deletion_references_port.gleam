import application/commands/ports/deletion_references as deletion_references_port
import domain/products/deletion/references as product_deletion_references
import domain/products/product
import gleam/result
import infrastructure/product_repository/sqlite_product_repository/shared
import sqlight

fn count_stock_references(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(Int, deletion_references_port.Error) {
  let id_str = shared.product_id_value(product_id)

  use rows <- result.try(
    sqlight.query(
      "select count(*) from stock_items where product_id = ?",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(fn(_) { deletion_references_port.DatabaseFailure }),
  )

  let assert [count] = rows
  Ok(count)
}

fn count_child_references(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(Int, deletion_references_port.Error) {
  let id_str = shared.product_id_value(product_id)

  use rows <- result.try(
    sqlight.query(
      "select count(*) from products where parent_product_id = ?",
      on: connection,
      with: [sqlight.text(id_str)],
      expecting: shared.total_decoder(),
    )
    |> result.map_error(fn(_) { deletion_references_port.DatabaseFailure }),
  )

  let assert [count] = rows
  Ok(count)
}

fn load_references(
  connection: sqlight.Connection,
  product_id: product.Id,
) -> Result(product_deletion_references.T, deletion_references_port.Error) {
  use stock_count <- result.try(count_stock_references(connection, product_id))
  use child_count <- result.try(count_child_references(connection, product_id))

  product_deletion_references.new(stock_count, child_count)
  |> result.map_error(fn(_) { deletion_references_port.InvalidReferenceData })
}

pub fn new(connection: sqlight.Connection) -> deletion_references_port.T {
  deletion_references_port.T(load: fn(product_id) {
    load_references(connection, product_id)
  })
}
