import application/commands/products/delete/ports
import application/shared/infrastructure_error
import common/product_id
import infrastructure/commands/decoder
import sqlight

fn has_children(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT COUNT(*)
      FROM products
      WHERE parent_product_id = ?
      ",
      on: connection,
      with: [sqlight.text(product_id.to_value(id))],
      expecting: decoder.count(),
    )

  case query_result {
    Ok([count]) -> Ok(count > 0)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result format for has_children query"
  }
}

pub fn new(connection: sqlight.Connection) -> ports.HasChildren {
  fn(id) { has_children(id, connection) }
}
