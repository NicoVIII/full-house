import application/commands/command_result
import application/commands/stock_items/create/ports
import application/shared/infrastructure_error
import common/product_id
import common/uuid_v7
import domain/stock_items/best_before_date
import domain/stock_items/stock_item
import gleam/bool
import gleam/result

pub type T {
  Command(product_id: product_id.T, best_before_date: best_before_date.T)
}

pub type Error {
  ProductDoesNotExist
  InfrastructureError(infrastructure_error.T)
}

pub fn handle(
  command command: T,
  ports ports: ports.T,
) -> command_result.T(Error) {
  let Command(product_id:, best_before_date:) = command

  use product_exists <- result.try(
    ports.does_product_exist(product_id)
    |> result.map_error(InfrastructureError),
  )

  use <- bool.guard(!product_exists, Error(ProductDoesNotExist))

  let new_item =
    stock_item.StockItem(id: uuid_v7.generate(), product_id:, best_before_date:)

  ports.create(new_item)
  |> result.map_error(InfrastructureError)
}
