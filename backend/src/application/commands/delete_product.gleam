import application/shared/infrastructure_error
import common/product_id
import domain/basics/non_empty_set
import domain/products/deletable_product_id
import domain/products/product
import gleam/result

pub type LoadProductError {
  LoadProductNotFound
  LoadProductInfrastructureError(infrastructure_error.T)
}

pub type LoadProductPort =
  fn(product_id.T) -> Result(product.T, LoadProductError)

pub type DeletionProperties {
  DeletionProperties(has_children: Bool, has_stock_items: Bool)
}

pub type DeletionPropertiesPort =
  fn(product_id.T) -> Result(DeletionProperties, infrastructure_error.T)

pub type DeletePort =
  fn(deletable_product_id.T) -> Result(Nil, infrastructure_error.T)

pub type Ports {
  Ports(
    get_deletion_properties: DeletionPropertiesPort,
    delete: DeletePort,
    load_product: LoadProductPort,
  )
}

pub type Command {
  Command(id: product_id.T)
}

pub type Error {
  ProductNotFound
  DomainError(non_empty_set.T(deletable_product_id.DeletionError))
  InfrastructureError(infrastructure_error.T)
}

pub fn execute(command: Command, ports: Ports) -> Result(Nil, Error) {
  let Command(id:) = command

  use product <- result.try(
    ports.load_product(id)
    |> result.map_error(fn(err) {
      case err {
        LoadProductNotFound -> ProductNotFound
        LoadProductInfrastructureError(e) -> InfrastructureError(e)
      }
    }),
  )

  use DeletionProperties(has_children, has_stock_items) <- result.try(
    ports.get_deletion_properties(id)
    |> result.map_error(InfrastructureError),
  )
  use deletable_product_id <- result.try(
    deletable_product_id.prove(product:, has_stock_items:, has_children:)
    |> result.map_error(DomainError),
  )

  ports.delete(deletable_product_id)
  |> result.map_error(InfrastructureError)
}
