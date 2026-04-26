import application/ports/products/child_references as child_references_port
import application/ports/products/delete as delete_product_port
import application/ports/products/stock_references as stock_references_port
import domain/product
import domain/product_deletion_policy
import gleam/result

pub type Error {
  DatabaseFailure
  ProductNotFound
  ProductHasStockItems
  ProductHasChildProducts
}

/// Execute the delete product command.
///
/// Flow:
/// 1. Query stock references for the product
/// 2. Apply deletion policy (fail if stock items exist)
/// 3. If valid, delegate to delete port
/// 4. Return result or error
pub fn execute(
  stock_repo: stock_references_port.T,
  child_repo: child_references_port.T,
  delete_repo: delete_product_port.T,
  product_id: product.Id,
) -> Result(Nil, Error) {
  use stock_count <- result.try(
    stock_repo.count_by_product_id(product_id)
    |> result.map_error(fn(_) { DatabaseFailure }),
  )

  use child_count <- result.try(
    child_repo.count_by_parent_id(product_id)
    |> result.map_error(fn(_) { DatabaseFailure }),
  )

  use _ <- result.try(
    product_deletion_policy.can_delete(stock_count, child_count)
    |> result.map_error(fn(reason) {
      case reason {
        product_deletion_policy.ProductHasStockItems -> ProductHasStockItems
        product_deletion_policy.ProductHasChildProducts ->
          ProductHasChildProducts
      }
    }),
  )

  use _ <- result.try(
    delete_repo.delete(product_id)
    |> result.map_error(map_delete_error),
  )

  Ok(Nil)
}

fn map_delete_error(error: delete_product_port.Error) -> Error {
  case error {
    delete_product_port.DatabaseFailure -> DatabaseFailure
    delete_product_port.ProductNotFound -> ProductNotFound
  }
}
