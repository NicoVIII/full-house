import application/commands/command_result
import application/commands/stock_items/delete/ports
import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date
import gleam/result

pub type T {
  Command(product_id: product_id.T, best_before_date: best_before_date.T)
}

pub type Error {
  StockItemNotFound
  InfrastructureError(infrastructure_error.T)
}

pub fn handle(
  command command: T,
  port port: ports.Delete,
) -> command_result.T(Error) {
  let Command(product_id:, best_before_date:) = command

  use outcome <- result.try(
    port(product_id, best_before_date)
    |> result.map_error(InfrastructureError),
  )

  case outcome {
    ports.Deleted -> Ok(Nil)
    ports.NotFound -> Error(StockItemNotFound)
  }
}
