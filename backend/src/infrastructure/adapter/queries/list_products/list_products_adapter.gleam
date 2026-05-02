import application/queries/common/page_limit
import application/queries/common/page_offset
import application/queries/common/product_query_model
import application/queries/list_products
import application/shared/infrastructure_error
import gleam/result
import infrastructure/adapter/decoder
import sqlight

fn query_total(
  connection: sqlight.Connection,
) -> Result(Int, infrastructure_error.T) {
  let total_query_result =
    sqlight.query(
      "SELECT COUNT(*) FROM products",
      with: [],
      on: connection,
      expecting: decoder.count(),
    )

  case total_query_result {
    Ok([total]) -> Ok(total)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
    Ok(_) -> panic as "Unexpected result format for total count query"
  }
}

fn query_list(
  limit: page_limit.T,
  offset: page_offset.T,
  connection: sqlight.Connection,
) -> Result(List(product_query_model.T), infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT
        p.id, p.name, p.parent_product_id,
        (SELECT GROUP_CONCAT(c.id) FROM products c WHERE c.parent_product_id = p.id) AS children_ids
      FROM products p
      LIMIT ? OFFSET ?
      ",
      with: [
        sqlight.int(page_limit.value(limit)),
        sqlight.int(page_offset.value(offset)),
      ],
      on: connection,
      expecting: decoder.product_query_model(),
    )

  case query_result {
    Ok(items) -> Ok(items)
    Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

fn list_products(
  limit: page_limit.T,
  offset: page_offset.T,
  connection: sqlight.Connection,
) -> Result(list_products.ListProductsResult, infrastructure_error.T) {
  use total <- result.try(query_total(connection))
  use model_list <- result.try(query_list(limit, offset, connection))

  Ok(list_products.ListProductsResult(
    data: model_list,
    limit: limit,
    offset: offset,
    total: total,
  ))
}

pub fn new(connection: sqlight.Connection) -> list_products.ListProductsPort {
  fn(limit, offset) { list_products(limit, offset, connection) }
}
