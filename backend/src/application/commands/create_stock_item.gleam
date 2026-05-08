import application/shared/infrastructure_error
import common/product_id
import common/uuid
import domain/stock_items/stock_item
import gleam/bool
import gleam/result

pub type ProductExistencePort =
  fn(product_id.T) -> Result(Bool, infrastructure_error.T)

pub type CreatePort =
  fn(stock_item.T) -> Result(Nil, infrastructure_error.T)

pub type Ports {
  Ports(does_product_exist: ProductExistencePort, create: CreatePort)
}

pub type Command {
  Command(product_id: product_id.T)
}

pub type Error {
  ProductDoesNotExist
  InfrastructureError(infrastructure_error.T)
}

pub fn execute(
  command command: Command,
  ports ports: Ports,
) -> Result(stock_item.T, Error) {
  let Command(product_id:) = command

  use product_exists <- result.try(
    ports.does_product_exist(product_id)
    |> result.map_error(InfrastructureError),
  )

  use <- bool.guard(!product_exists, Error(ProductDoesNotExist))

  let new_item = stock_item.StockItem(id: uuid.generate_v7(), product_id:)

  use Nil <- result.try(
    ports.create(new_item)
    |> result.map_error(InfrastructureError),
  )

  Ok(new_item)
}
