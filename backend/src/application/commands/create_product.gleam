import application/shared/infrastructure_error
import common/product_id
import domain/products/existing_product_id
import domain/products/product
import domain/products/product_name
import gleam/option.{type Option, None, Some}
import gleam/result

pub type ProductExistencePort =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type CreatePort =
  fn(product.T) -> Result(Nil, infrastructure_error.T)

pub type Ports {
  Ports(does_product_exist: ProductExistencePort, create: CreatePort)
}

pub type Command {
  Command(name: product_name.T, parent_product_id: Option(product_id.T))
}

pub type Error {
  ParentDoesNotExist
  InfrastructureError(infrastructure_error.T)
}

pub fn execute(command: Command, ports: Ports) -> Result(product.T, Error) {
  let Command(name, parent_product_id_opt) = command

  // Prepare parent product id if provided
  use parent_product_id <- result.try(case parent_product_id_opt {
    None -> Ok(None)
    Some(parent_id) -> {
      use parent_exists <- result.try(
        ports.does_product_exist(parent_id)
        |> result.map_error(InfrastructureError),
      )

      case existing_product_id.prove(parent_id, parent_exists) {
        Ok(existing_id) -> Ok(Some(existing_id))
        Error(existing_product_id.ProductNotFound) -> Error(ParentDoesNotExist)
      }
    }
  })

  let new_product =
    product.T(
      id: product_id.generate(),
      name: name,
      parent_product_id: parent_product_id,
    )

  use Nil <- result.try(
    ports.create(new_product)
    |> result.map_error(InfrastructureError),
  )

  Ok(new_product)
}
