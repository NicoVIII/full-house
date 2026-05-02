import application/commands/delete_product
import application/shared/infrastructure_error
import common/product_id
import domain/products/product
import infrastructure/adapter/decoder
import sqlight

fn get_product(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(product.T, delete_product.LoadProductError) {
  let query_result =
    sqlight.query(
      "
      SELECT
        p.id, p.name, p.parent_product_id
      FROM products p
      WHERE p.id = ?
      ",
      with: [sqlight.text(product_id.value(id))],
      on: connection,
      expecting: decoder.product(),
    )

  case query_result {
    Ok([model]) -> Ok(model)
    Ok([]) -> Error(delete_product.LoadProductNotFound)
    Error(_) ->
      Error(delete_product.LoadProductInfrastructureError(
        infrastructure_error.DatabaseFailure,
      ))
    Ok(_) -> panic as "Unexpected: multiple rows for single product query"
  }
}

pub fn new(connection: sqlight.Connection) -> delete_product.LoadProductPort {
  fn(id) { get_product(id, connection) }
}
