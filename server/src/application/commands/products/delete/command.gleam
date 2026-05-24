import application/commands/command_result
import application/commands/products/delete/ports
import application/shared/infrastructure_error
import common/product_id
import domain/basics/non_empty_set
import domain/products/product
import gleam/result

pub type T {
  Command(id: product_id.T)
}

pub type Error {
  ProductNotFound
  DomainError(non_empty_set.T(product.DeletionError))
  InfrastructureError(infrastructure_error.T)
}

pub fn handle(
  command command: T,
  ports ports: ports.T,
) -> command_result.T(Error) {
  let Command(id:) = command

  // Load
  use product <- result.try(
    ports.load_product(id)
    |> result.map_error(fn(err) {
      case err {
        ports.LoadProductNotFound -> ProductNotFound
        ports.LoadProductInfrastructureError(e) -> InfrastructureError(e)
      }
    }),
  )

  // Perform
  use has_children <- result.try(
    ports.has_children(id)
    |> result.map_error(InfrastructureError),
  )
  use has_stock_items <- result.try(
    ports.has_stock_items(id)
    |> result.map_error(InfrastructureError),
  )
  use deletable_product_id <- result.try(
    product.delete(
      product:,
      context: product.DeletionContext(has_children, has_stock_items),
    )
    |> result.map_error(DomainError),
  )

  // Persist
  ports.delete(deletable_product_id)
  |> result.map_error(InfrastructureError)
}
