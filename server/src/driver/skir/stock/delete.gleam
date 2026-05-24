import application/commands/stock_items/delete/command
import application/commands/stock_items/delete/ports
import application/shared/infrastructure_error
import driver/shared/parse_error
import driver/shared/stock_items/delete/request_parser
import driver/skirout/stock_items/commands
import gleam/result
import skir_client/service.{ServiceError}

fn map_error(error: command.Error) -> service.ServiceError {
  case error {
    command.StockItemNotFound ->
      service.ServiceError(service.E404xNotFound, "stock item not found")
    command.InfrastructureError(infrastructure_error.DatabaseFailure) ->
      service.ServiceError(
        service.E500xInternalServerError,
        "infrastructure error",
      )
  }
}

pub fn handle(
  request: commands.DeleteStockItemRequest,
  port: ports.Delete,
) -> Result(commands.DeleteStockItemResponse, service.ServiceError) {
  use command <- result.try(
    request_parser.parse(request)
    |> result.map_error(fn(e) {
      case e {
        parse_error.ParseError(message) ->
          ServiceError(service.E400xBadRequest, message)
      }
    }),
  )

  use Nil <- result.try(
    command.handle(command:, port:)
    |> result.map_error(map_error),
  )

  Ok(commands.DeleteStockItemResponseSuccess)
}
