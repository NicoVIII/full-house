import application/shared/infrastructure_error
import common/product_id
import domain/products/product
import infrastructure/commands/decoder
import sqlight

pub type Error {
  NotFound
  InfrastructureError(infrastructure_error.T)
}

pub fn get(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(product.T, Error) {
  let query_result =
    sqlight.query(
      "
      SELECT
        p.id, p.name, p.parent_product_id
      FROM products p
      WHERE p.id = ?
      ",
      with: [sqlight.text(product_id.to_value(id))],
      on: connection,
      expecting: decoder.product(),
    )

  case query_result {
    Ok([model]) -> Ok(model)
    Ok([]) -> Error(NotFound)
    Error(_) -> Error(InfrastructureError(infrastructure_error.DatabaseFailure))
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected: multiple rows for single product query"
  }
}
