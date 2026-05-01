import application/commands/ports/delete as delete_product_port
import application/commands/ports/deletion_references as deletion_references_port
import domain/products/deletion/command as delete_product_command
import domain/products/deletion/policy as product_deletion_policy
import domain/products/product
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
/// 1. Load deletion reference facts
/// 2. Apply domain deletion policy
/// 3. If allowed, delegate to delete port
/// 4. If a concurrent reference appears, re-check and map it explicitly
pub fn execute(
  references_repo: deletion_references_port.T,
  delete_repo: delete_product_port.T,
  command: delete_product_command.T,
) -> Result(Nil, Error) {
  let delete_product_command.Command(product_id) = command

  use references <- result.try(
    references_repo.load(product_id)
    |> result.map_error(map_load_references_error),
  )

  use _ <- result.try(
    map_policy_decision(product_deletion_policy.decide(references)),
  )

  case delete_repo.delete(product_id) {
    Ok(Nil) -> Ok(Nil)
    Error(error) -> map_delete_error(references_repo, product_id, error)
  }
}

fn map_policy_decision(
  decision: product_deletion_policy.Decision,
) -> Result(Nil, Error) {
  case decision {
    product_deletion_policy.CanDelete -> Ok(Nil)
    product_deletion_policy.CannotDelete([first, ..]) ->
      case first {
        product_deletion_policy.HasStockItems(_) -> Error(ProductHasStockItems)
        product_deletion_policy.HasChildProducts(_) ->
          Error(ProductHasChildProducts)
      }
    product_deletion_policy.CannotDelete([]) -> Ok(Nil)
  }
}

fn map_load_references_error(error: deletion_references_port.Error) -> Error {
  case error {
    deletion_references_port.DatabaseFailure -> DatabaseFailure
    deletion_references_port.InvalidReferenceData -> DatabaseFailure
  }
}

fn map_delete_error(
  references_repo: deletion_references_port.T,
  product_id: product.Id,
  error: delete_product_port.Error,
) -> Result(Nil, Error) {
  case error {
    delete_product_port.DatabaseFailure -> Error(DatabaseFailure)
    delete_product_port.ProductNotFound -> Error(ProductNotFound)
    delete_product_port.ProductStillReferenced ->
      recheck_policy_decision(references_repo, product_id)
  }
}

fn recheck_policy_decision(
  references_repo: deletion_references_port.T,
  product_id: product.Id,
) -> Result(Nil, Error) {
  use references <- result.try(
    references_repo.load(product_id)
    |> result.map_error(map_load_references_error),
  )

  case product_deletion_policy.decide(references) {
    product_deletion_policy.CanDelete -> Error(DatabaseFailure)
    blocked -> map_policy_decision(blocked)
  }
}
