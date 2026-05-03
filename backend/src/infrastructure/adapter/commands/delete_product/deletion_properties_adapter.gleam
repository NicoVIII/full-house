import application/commands/delete_product
import application/shared/infrastructure_error
import common/product_id
import gleam/io
import infrastructure/adapter/decoder
import sqlight

fn query_has_children(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT EXISTS (
        SELECT 1 FROM products
        WHERE parent_product_id = ?
      )
      ",
      with: [sqlight.text(product_id.value(id))],
      on: connection,
      expecting: decoder.exists(),
    )

  case query_result {
    Ok([has_children]) -> Ok(has_children)
    Error(err) -> {
      io.println_error("Database error: " <> err.message)
      Error(infrastructure_error.DatabaseFailure)
    }
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result from database"
  }
}

fn query_has_stock_items(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(Bool, infrastructure_error.T) {
  let query_result =
    sqlight.query(
      "
      SELECT EXISTS (
        SELECT 1 FROM stock_items
        WHERE product_id = ?
      )
      ",
      with: [sqlight.text(product_id.value(id))],
      on: connection,
      expecting: decoder.exists(),
    )

  case query_result {
    Ok([has_stock_items]) -> Ok(has_stock_items)
    Error(err) -> {
      io.println_error("Database error: " <> err.message)
      Error(infrastructure_error.DatabaseFailure)
    }
    // nolint: avoid_panic
    Ok(_) -> panic as "Unexpected result from database"
  }
}

fn load_properties(
  id: product_id.T,
  connection: sqlight.Connection,
) -> Result(delete_product.DeletionProperties, infrastructure_error.T) {
  let has_children = query_has_children(id, connection)
  let has_stock_items = query_has_stock_items(id, connection)

  case has_children, has_stock_items {
    Ok(has_children), Ok(has_stock_items) ->
      Ok(delete_product.DeletionProperties(has_children, has_stock_items))
    Error(_), _ | _, Error(_) -> Error(infrastructure_error.DatabaseFailure)
  }
}

pub fn new(
  connection: sqlight.Connection,
) -> delete_product.DeletionPropertiesPort {
  fn(id) { load_properties(id, connection) }
}
