import application/shared/infrastructure_error
import common/product_id
import domain/stock_items/best_before_date
import gleam/result

pub type RemoveOutcome {
  Removed(Int)
  NotFound
}

pub type RemovePort =
  fn(product_id.T, best_before_date.T) ->
    Result(RemoveOutcome, infrastructure_error.T)

pub type Command {
  Command(product_id: product_id.T, best_before_date: best_before_date.T)
}

pub type Response {
  Response(
    product_id: product_id.T,
    best_before_date: best_before_date.T,
    remaining_quantity: Int,
  )
}

pub type Error {
  StockItemNotFound
  InfrastructureError(infrastructure_error.T)
}

pub fn execute(
  command command: Command,
  remove remove: RemovePort,
) -> Result(Response, Error) {
  let Command(product_id:, best_before_date:) = command

  use outcome <- result.try(
    remove(product_id, best_before_date)
    |> result.map_error(InfrastructureError),
  )

  case outcome {
    Removed(remaining_quantity) ->
      Ok(Response(product_id:, best_before_date:, remaining_quantity:))
    NotFound -> Error(StockItemNotFound)
  }
}
