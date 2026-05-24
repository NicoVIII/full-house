import application/commands/stock_items/delete/command
import common/product_id
import domain/stock_items/best_before_date
import driver/shared/parse_error.{ParseError}
import driver/skirout/stock_items/commands
import gleam/result

type Error {
  InvalidProductId
  InvalidBestBeforeDate
}

fn parse_internal(request: commands.DeleteStockItemRequest) {
  use product_id <- result.try(
    product_id.new(request.product_id)
    |> result.map_error(fn(_) { InvalidProductId }),
  )
  use best_before_date <- result.try(
    best_before_date.new(request.best_before_date)
    |> result.map_error(fn(_) { InvalidBestBeforeDate }),
  )

  Ok(command.Command(product_id:, best_before_date:))
}

pub fn parse(
  request: commands.DeleteStockItemRequest,
) -> Result(command.T, parse_error.T) {
  parse_internal(request)
  |> result.map_error(fn(e) {
    case e {
      InvalidProductId -> ParseError("product_id is invalid")
      InvalidBestBeforeDate -> ParseError("best_before_date is invalid")
    }
  })
}
