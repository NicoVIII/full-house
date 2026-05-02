import application/queries/common/product_query_model
import application/queries/get_product
import application/shared/infrastructure_error
import common/product_id
import infrastructure/adapter/decoder
import sqlight

fn get_product(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(product_query_model.T, get_product.GetProductError) {
  let query_result =
    sqlight.query(
      "
      SELECT
        p.id, p.name, p.parent_product_id,
        (SELECT GROUP_CONCAT(c.id) FROM products c WHERE c.parent_product_id = p.id) AS children_ids
      FROM products p
      WHERE p.id = ?
      ",
      with: [sqlight.text(product_id.value(id))],
      on: connection,
      expecting: decoder.product_query_model(),
    )

  case query_result {
    Ok([model]) -> Ok(model)
    Ok([]) -> Error(get_product.ProductNotFound)
    Error(_) ->
      Error(get_product.InfrastructureError(
        infrastructure_error.DatabaseFailure,
      ))
    Ok(_) -> panic as "Unexpected: multiple rows for single product query"
  }
}

pub fn new(connection: sqlight.Connection) -> get_product.GetProductPort {
  fn(id) { get_product(id, connection) }
}
